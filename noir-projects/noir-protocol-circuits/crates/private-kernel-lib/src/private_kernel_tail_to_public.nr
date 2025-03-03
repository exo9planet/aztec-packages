use crate::kernel_circuit_public_inputs_composer::KernelCircuitPublicInputsComposer;
use dep::reset_kernel_lib::{NullifierReadRequestHints, PrivateValidationRequestProcessor};
use dep::types::{
    abis::{
    kernel_data::PrivateKernelData, kernel_circuit_public_inputs::PublicKernelCircuitPublicInputs,
    note_hash::NoteHashContext, nullifier::Nullifier, side_effect::SideEffect
},
    constants::{
    MAX_NEW_NOTE_HASHES_PER_TX, MAX_NEW_NULLIFIERS_PER_TX, MAX_NOTE_HASH_READ_REQUESTS_PER_TX,
    MAX_NULLIFIER_KEY_VALIDATION_REQUESTS_PER_TX, MAX_ENCRYPTED_LOGS_PER_TX, MAX_UNENCRYPTED_LOGS_PER_TX
},
    grumpkin_private_key::GrumpkinPrivateKey, utils::arrays::array_length
};

// Can just be PublicKernelCircuitPublicInputs.
struct PrivateKernelTailToPublicOutputs {
    note_hashes: [NoteHashContext; MAX_NEW_NOTE_HASHES_PER_TX],
    nullifiers: [Nullifier; MAX_NEW_NULLIFIERS_PER_TX],
}

struct PrivateKernelTailToPublicHints {
    transient_nullifier_indexes_for_note_hashes: [u64; MAX_NEW_NOTE_HASHES_PER_TX],
    transient_note_hash_indexes_for_nullifiers: [u64; MAX_NEW_NULLIFIERS_PER_TX],
    note_hash_read_request_hints: [u64; MAX_NOTE_HASH_READ_REQUESTS_PER_TX],
    nullifier_read_request_hints: NullifierReadRequestHints,
    master_nullifier_secret_keys: [GrumpkinPrivateKey; MAX_NULLIFIER_KEY_VALIDATION_REQUESTS_PER_TX],
    sorted_new_note_hashes: [NoteHashContext; MAX_NEW_NOTE_HASHES_PER_TX],
    sorted_new_note_hashes_indexes: [u64; MAX_NEW_NOTE_HASHES_PER_TX],
    sorted_new_nullifiers: [Nullifier; MAX_NEW_NULLIFIERS_PER_TX],
    sorted_new_nullifiers_indexes: [u64; MAX_NEW_NULLIFIERS_PER_TX],
    sorted_encrypted_log_hashes: [SideEffect; MAX_ENCRYPTED_LOGS_PER_TX],
    sorted_encrypted_log_hashes_indexes: [u64; MAX_ENCRYPTED_LOGS_PER_TX],
    sorted_unencrypted_log_hashes: [SideEffect; MAX_UNENCRYPTED_LOGS_PER_TX],
    sorted_unencrypted_log_hashes_indexes: [u64; MAX_UNENCRYPTED_LOGS_PER_TX],
}

struct PrivateKernelTailToPublicCircuitPrivateInputs {
    previous_kernel: PrivateKernelData,
    outputs: PrivateKernelTailToPublicOutputs,
    hints: PrivateKernelTailToPublicHints
}

impl PrivateKernelTailToPublicCircuitPrivateInputs {
    pub fn execute(self) -> PublicKernelCircuitPublicInputs {
        let previous_public_inputs = self.previous_kernel.public_inputs;
        assert(
            array_length(previous_public_inputs.end.public_call_stack) != 0, "Public call stack must not be empty when exporting public kernel data from the tail circuit"
        );

        let nullifier_tree_root = previous_public_inputs.constants.historical_header.state.partial.nullifier_tree.root;
        let request_processor = PrivateValidationRequestProcessor {
            validation_requests: previous_public_inputs.validation_requests,
            note_hash_read_request_hints: self.hints.note_hash_read_request_hints,
            pending_note_hashes: previous_public_inputs.end.new_note_hashes,
            nullifier_read_request_hints: self.hints.nullifier_read_request_hints,
            pending_nullifiers: previous_public_inputs.end.new_nullifiers,
            master_nullifier_secret_keys: self.hints.master_nullifier_secret_keys,
            nullifier_tree_root
        };
        request_processor.validate();

        let mut composer = KernelCircuitPublicInputsComposer::new(
            self.previous_kernel,
            self.outputs.note_hashes,
            self.outputs.nullifiers,
            self.hints.transient_nullifier_indexes_for_note_hashes,
            self.hints.transient_note_hash_indexes_for_nullifiers,
            self.hints.sorted_new_note_hashes,
            self.hints.sorted_new_note_hashes_indexes,
            self.hints.sorted_new_nullifiers,
            self.hints.sorted_new_nullifiers_indexes,
            self.hints.sorted_encrypted_log_hashes,
            self.hints.sorted_encrypted_log_hashes_indexes,
            self.hints.sorted_unencrypted_log_hashes,
            self.hints.sorted_unencrypted_log_hashes_indexes
        );
        composer.compose_public().finish_to_public()
    }
}

mod tests {
    use crate::private_kernel_tail_to_public::{
        PrivateKernelTailToPublicCircuitPrivateInputs, PrivateKernelTailToPublicHints,
        PrivateKernelTailToPublicOutputs
    };
    use dep::reset_kernel_lib::{
        tests::{
        nullifier_read_request_hints_builder::NullifierReadRequestHintsBuilder,
        squash_transient_data::{squash_transient_note_hashes, squash_transient_nullifiers}
    },
        reset::read_request::{PendingReadHint, ReadRequestState, ReadRequestStatus}
    };
    use dep::types::constants::{
        MAX_NOTE_HASH_READ_REQUESTS_PER_TX, MAX_NEW_NOTE_HASHES_PER_TX, MAX_NEW_NULLIFIERS_PER_TX,
        MAX_NULLIFIER_READ_REQUESTS_PER_TX, MAX_NULLIFIER_KEY_VALIDATION_REQUESTS_PER_TX,
        DA_BYTES_PER_FIELD, DA_GAS_PER_BYTE
    };
    use dep::types::{
        abis::{
        kernel_circuit_public_inputs::PublicKernelCircuitPublicInputs, gas::Gas,
        note_hash::{NoteHash, NoteHashContext}, nullifier::Nullifier, side_effect::{SideEffect, Ordered}
    },
        grumpkin_private_key::GrumpkinPrivateKey,
        hash::{compute_note_hash_nonce, compute_unique_siloed_note_hash},
        tests::{fixture_builder::FixtureBuilder, sort::sort_get_sorted_hints},
        utils::{arrays::{array_eq, array_length}}, traits::is_empty_array
    };

    // TODO: Reduce the duplicated code/tests for PrivateKernelTailToPublicInputs and PrivateKernelTailInputs.
    struct PrivateKernelTailToPublicInputsBuilder {
        previous_kernel: FixtureBuilder,
        note_hash_read_request_hints: [u64; MAX_NOTE_HASH_READ_REQUESTS_PER_TX],
        transient_nullifier_indexes_for_note_hashes: [u64; MAX_NEW_NOTE_HASHES_PER_TX],
        transient_note_hash_indexes_for_nullifiers: [u64; MAX_NEW_NULLIFIERS_PER_TX],
        nullifier_read_request_hints_builder: NullifierReadRequestHintsBuilder,
    }

    impl PrivateKernelTailToPublicInputsBuilder {
        pub fn new() -> Self {
            let mut previous_kernel = FixtureBuilder::new();
            previous_kernel.tx_context.gas_settings.gas_limits = Gas::new(1_000_000, 1_000_000);
            previous_kernel.append_new_nullifiers(1);
            previous_kernel.push_public_call_request(1, false);

            PrivateKernelTailToPublicInputsBuilder {
                previous_kernel,
                note_hash_read_request_hints: [0; MAX_NOTE_HASH_READ_REQUESTS_PER_TX],
                transient_nullifier_indexes_for_note_hashes: [MAX_NEW_NULLIFIERS_PER_TX; MAX_NEW_NOTE_HASHES_PER_TX],
                transient_note_hash_indexes_for_nullifiers: [MAX_NEW_NOTE_HASHES_PER_TX; MAX_NEW_NULLIFIERS_PER_TX],
                nullifier_read_request_hints_builder: NullifierReadRequestHintsBuilder::new(MAX_NULLIFIER_READ_REQUESTS_PER_TX)
            }
        }

        // A helper function that uses the first nullifer in the previous kernel to compute the unique siloed
        // note_hashes for the given note_hashes.
        pub fn compute_unique_siloed_note_hashes<N>(
            self,
            note_hashes: [NoteHashContext; N]
        ) -> [NoteHash; N] {
            let first_nullifier = self.previous_kernel.new_nullifiers.get_unchecked(0);
            let mut unique_siloed_note_hashes = [NoteHash::empty(); N];
            for i in 0..N {
                if note_hashes[i].value != 0 {
                    let nonce = compute_note_hash_nonce(first_nullifier.value, i);
                    unique_siloed_note_hashes[i] = NoteHash {
                        value: compute_unique_siloed_note_hash(nonce, note_hashes[i].value),
                        counter: 0, // Counter is cleared so it's not exposed to the public.
                    };
                }
            }
            unique_siloed_note_hashes
        }

        pub fn add_pending_note_hash_read_request(&mut self, note_hash_index: u64) {
            let read_request_index = self.previous_kernel.add_read_request_for_pending_note_hash(note_hash_index);
            self.note_hash_read_request_hints[read_request_index] = note_hash_index;
        }

        pub fn add_pending_nullifier_read_request(&mut self, nullifier_index_offset_one: u64) {
            let nullifier_index = nullifier_index_offset_one + 1; // + 1 is for the first nullifier
            let read_request_index = self.previous_kernel.add_read_request_for_pending_nullifier(nullifier_index);
            let hint_index = self.nullifier_read_request_hints_builder.pending_read_hints.len();
            let hint = PendingReadHint { read_request_index, pending_value_index: nullifier_index };
            self.nullifier_read_request_hints_builder.pending_read_hints.push(hint);
            self.nullifier_read_request_hints_builder.read_request_statuses[read_request_index] = ReadRequestStatus { state: ReadRequestState.PENDING, hint_index };
        }

        pub fn nullify_pending_note_hash(&mut self, nullifier_index: u64, note_hash_index: u64) {
            self.previous_kernel.new_note_hashes.storage[note_hash_index].nullifier_counter = self.previous_kernel.new_nullifiers.get(nullifier_index).counter;
            self.previous_kernel.new_nullifiers.storage[nullifier_index].note_hash = self.previous_kernel.new_note_hashes.get(note_hash_index).value;
            self.transient_nullifier_indexes_for_note_hashes[note_hash_index] = nullifier_index;
            self.transient_note_hash_indexes_for_nullifiers[nullifier_index] = note_hash_index;
        }

        pub fn execute(&mut self) -> PublicKernelCircuitPublicInputs {
            let sorted = sort_get_sorted_hints(
                self.previous_kernel.new_note_hashes.storage,
                |a: NoteHashContext, b: NoteHashContext| a.counter < b.counter
            );
            let sorted_new_note_hashes = sorted.sorted_array;
            let sorted_new_note_hashes_indexes = sorted.sorted_index_hints;

            let mut sorted_note_hash_read_request_hints = [0; MAX_NOTE_HASH_READ_REQUESTS_PER_TX];
            for i in 0..sorted_note_hash_read_request_hints.len() {
                sorted_note_hash_read_request_hints[i] = sorted_new_note_hashes_indexes[self.note_hash_read_request_hints[i]];
            }

            let sorted = sort_get_sorted_hints(
                self.previous_kernel.new_nullifiers.storage,
                |a: Nullifier, b: Nullifier| a.counter < b.counter
            );
            let sorted_new_nullifiers = sorted.sorted_array;
            let sorted_new_nullifiers_indexes = sorted.sorted_index_hints;

            let sorted = sort_get_sorted_hints(
                self.previous_kernel.encrypted_logs_hashes.storage,
                |a: SideEffect, b: SideEffect| a.counter < b.counter
            );
            let sorted_encrypted_log_hashes = sorted.sorted_array;
            let sorted_encrypted_log_hashes_indexes = sorted.sorted_index_hints;

            let sorted = sort_get_sorted_hints(
                self.previous_kernel.unencrypted_logs_hashes.storage,
                |a: SideEffect, b: SideEffect| a.counter < b.counter
            );
            let sorted_unencrypted_log_hashes = sorted.sorted_array;
            let sorted_unencrypted_log_hashes_indexes = sorted.sorted_index_hints;

            let mut sorted_transient_nullifier_indexes_for_note_hashes = [MAX_NEW_NULLIFIERS_PER_TX; MAX_NEW_NOTE_HASHES_PER_TX];
            for i in 0..self.transient_nullifier_indexes_for_note_hashes.len() {
                let old_index = self.transient_nullifier_indexes_for_note_hashes[i];
                if old_index != MAX_NEW_NULLIFIERS_PER_TX {
                    let new_note_hash_index = sorted_new_note_hashes_indexes[i];
                    sorted_transient_nullifier_indexes_for_note_hashes[new_note_hash_index] = sorted_new_nullifiers_indexes[old_index];
                }
            }

            let mut sorted_transient_note_hash_indexes_for_nullifiers = [MAX_NEW_NOTE_HASHES_PER_TX; MAX_NEW_NULLIFIERS_PER_TX];
            for i in 0..self.transient_note_hash_indexes_for_nullifiers.len() {
                let old_index = self.transient_note_hash_indexes_for_nullifiers[i];
                if old_index != MAX_NEW_NOTE_HASHES_PER_TX {
                    let new_nullifier_index = sorted_new_nullifiers_indexes[i];
                    sorted_transient_note_hash_indexes_for_nullifiers[new_nullifier_index] = sorted_new_note_hashes_indexes[old_index];
                }
            }

            let outputs = PrivateKernelTailToPublicOutputs {
                note_hashes: squash_transient_note_hashes(sorted_new_note_hashes),
                nullifiers: squash_transient_nullifiers(sorted_new_nullifiers)
            };

            let hints = PrivateKernelTailToPublicHints {
                transient_nullifier_indexes_for_note_hashes: sorted_transient_nullifier_indexes_for_note_hashes,
                transient_note_hash_indexes_for_nullifiers: sorted_transient_note_hash_indexes_for_nullifiers,
                note_hash_read_request_hints: sorted_note_hash_read_request_hints,
                nullifier_read_request_hints: self.nullifier_read_request_hints_builder.to_hints(),
                master_nullifier_secret_keys: [GrumpkinPrivateKey::empty(); MAX_NULLIFIER_KEY_VALIDATION_REQUESTS_PER_TX],
                sorted_new_note_hashes,
                sorted_new_note_hashes_indexes,
                sorted_new_nullifiers,
                sorted_new_nullifiers_indexes,
                sorted_encrypted_log_hashes,
                sorted_encrypted_log_hashes_indexes,
                sorted_unencrypted_log_hashes,
                sorted_unencrypted_log_hashes_indexes
            };

            let kernel = PrivateKernelTailToPublicCircuitPrivateInputs { previous_kernel: self.previous_kernel.to_private_kernel_data(), outputs, hints };
            kernel.execute()
        }

        pub fn failed(&mut self) {
            let _ = self.execute();
        }

        pub fn succeeded(&mut self) {
            let _ = self.execute();
        }
    }

    #[test]
    unconstrained fn native_matching_one_read_request_to_note_hash_works() {
        let mut builder = PrivateKernelTailToPublicInputsBuilder::new();

        builder.previous_kernel.append_new_note_hashes(1);
        builder.add_pending_note_hash_read_request(0);

        let unique_siloed_note_hashes = builder.compute_unique_siloed_note_hashes(builder.previous_kernel.new_note_hashes.storage);

        let public_inputs = builder.execute();
        assert(
            array_eq(
                public_inputs.end.new_note_hashes,
                [unique_siloed_note_hashes[0]]
            )
        );
    }

    #[test]
    unconstrained fn native_matching_some_read_requests_to_note_hashes_works() {
        let num_non_revertible = 3;
        let num_revertible = 2;

        let mut builder = PrivateKernelTailToPublicInputsBuilder::new();
        builder.previous_kernel.append_new_note_hashes(num_non_revertible + num_revertible);
        // prepare for the split: first MAX_NON_REVERTIBLE_NOTE_HASHES_PER_TX are added to end_non_revertible_accumulted_data
        // neeed to take the counter of the side effect at the given index because
        builder.previous_kernel.min_revertible_side_effect_counter = builder.previous_kernel.new_note_hashes.get(num_non_revertible).counter;
        // Read the hash at index 1;
        builder.add_pending_note_hash_read_request(1);
        // Read the hash at index 3;
        builder.add_pending_note_hash_read_request(3);
        let unique_siloed_note_hashes = builder.compute_unique_siloed_note_hashes(builder.previous_kernel.new_note_hashes.storage);
        let public_inputs = builder.execute();
        assert(
            array_eq(
                public_inputs.end_non_revertible.new_note_hashes,
                [unique_siloed_note_hashes[0], unique_siloed_note_hashes[1], unique_siloed_note_hashes[2]]
            )
        );
        assert(
            array_eq(
                public_inputs.end.new_note_hashes,
                [unique_siloed_note_hashes[3], unique_siloed_note_hashes[4]]
            )
        );
    }

    #[test(should_fail_with="Hinted note hash does not match read request")]
    unconstrained fn native_read_request_unknown_fails() {
        let mut builder = PrivateKernelTailToPublicInputsBuilder::new();
        builder.previous_kernel.append_new_note_hashes(1);
        builder.add_pending_note_hash_read_request(0);
        // Tweak the read request so that it does not match the hash at index 0;
        let read_request = builder.previous_kernel.note_hash_read_requests.pop();
        builder.previous_kernel.note_hash_read_requests.push(SideEffect { value: read_request.value + 1, counter: 0 });
        builder.failed();
    }

    #[test]
    unconstrained fn one_pending_nullifier_read_request() {
        let mut builder = PrivateKernelTailToPublicInputsBuilder::new();

        builder.previous_kernel.append_new_nullifiers(3);
        builder.add_pending_nullifier_read_request(1);

        builder.succeeded();
    }

    #[test]
    unconstrained fn two_pending_nullifier_read_requests() {
        let mut builder = PrivateKernelTailToPublicInputsBuilder::new();

        builder.previous_kernel.append_new_nullifiers(3);
        builder.add_pending_nullifier_read_request(1);
        builder.add_pending_nullifier_read_request(0);

        builder.succeeded();
    }

    #[test(should_fail_with="Hinted value does not match read request")]
    unconstrained fn pending_nullifier_read_request_wrong_hint_fails() {
        let mut builder = PrivateKernelTailToPublicInputsBuilder::new();

        builder.previous_kernel.append_new_nullifiers(3);
        builder.add_pending_nullifier_read_request(1);
        let mut hint = builder.nullifier_read_request_hints_builder.pending_read_hints.pop();
        assert(hint.pending_value_index == 2);
        hint.pending_value_index = 1;
        builder.nullifier_read_request_hints_builder.pending_read_hints.push(hint);

        builder.failed();
    }

    #[test(should_fail_with="Read request counter must be greater than counter of the value being read")]
    unconstrained fn pending_nullifier_read_request_reads_before_value_fails() {
        let mut builder = PrivateKernelTailToPublicInputsBuilder::new();

        builder.previous_kernel.append_new_nullifiers(3);
        builder.add_pending_nullifier_read_request(1);
        let nullifier_being_read = builder.previous_kernel.new_nullifiers.storage[2];
        let mut read_request = builder.previous_kernel.nullifier_read_requests.pop();
        read_request.counter = nullifier_being_read.counter - 1;
        builder.previous_kernel.nullifier_read_requests.push(read_request);

        builder.failed();
    }

    #[test]
    unconstrained fn native_squash_one_of_one_transient_matches_works() {
        let mut builder = PrivateKernelTailToPublicInputsBuilder::new();
        builder.previous_kernel.append_new_note_hashes(1);
        builder.previous_kernel.append_new_nullifiers(2);
        // The nullifier at index 1 is nullifying the hash at index 0;
        builder.nullify_pending_note_hash(1, 0);
        let new_nullifiers = builder.previous_kernel.new_nullifiers.storage;
        let public_inputs = builder.execute();
        assert(is_empty_array(public_inputs.end.new_note_hashes));

        // The nullifier at index 1 is chopped.
        assert(
            array_eq(
                public_inputs.end.new_nullifiers,
                [new_nullifiers[0], new_nullifiers[2]]
            )
        );
    }

    #[test]
    unconstrained fn native_squash_one_of_two_transient_matches_works() {
        let mut builder = PrivateKernelTailToPublicInputsBuilder::new();
        builder.previous_kernel.append_new_note_hashes(2);
        builder.previous_kernel.append_new_nullifiers(2);
        // The nullifier at index 1 is nullifying the hash at index 0;
        builder.nullify_pending_note_hash(1, 0);
        let new_note_hashes = builder.previous_kernel.new_note_hashes.storage;
        // The 0th hash will be chopped.
        let unique_siloed_note_hashes = builder.compute_unique_siloed_note_hashes([new_note_hashes[1]]);
        let new_nullifiers = builder.previous_kernel.new_nullifiers.storage;
        let public_inputs = builder.execute();
        assert(
            array_eq(
                public_inputs.end.new_note_hashes,
                [unique_siloed_note_hashes[0]]
            )
        );
        // The nullifier at index 1 is chopped.
        assert(
            array_eq(
                public_inputs.end.new_nullifiers,
                [new_nullifiers[0], new_nullifiers[2]]
            )
        );
    }

    #[test]
    unconstrained fn native_squash_two_of_two_transient_matches_works() {
        let mut builder = PrivateKernelTailToPublicInputsBuilder::new();
        builder.previous_kernel.append_new_note_hashes(2);
        builder.previous_kernel.append_new_nullifiers(2);
        // The nullifier at index 1 is nullifying the hash at index 1;
        builder.nullify_pending_note_hash(1, 1);
        // The nullifier at index 2 is nullifying the hash at index 0;
        builder.nullify_pending_note_hash(2, 0);
        let new_nullifiers = builder.previous_kernel.new_nullifiers.storage;
        let public_inputs = builder.execute();

        // Only the first nullifier is left after squashing.
        assert(is_empty_array(public_inputs.end.new_note_hashes));
        assert(array_eq(public_inputs.end.new_nullifiers, [new_nullifiers[0]]));
    }

    #[test]
    unconstrained fn ordering_of_note_hashes_and_nullifiers() {
        let mut builder = PrivateKernelTailToPublicInputsBuilder::new();

        builder.previous_kernel.append_new_note_hashes(10);
        builder.previous_kernel.append_new_nullifiers(10);

        let sorted_note_hashes = builder.previous_kernel.new_note_hashes.storage;
        let sorted_nullifiers = builder.previous_kernel.new_nullifiers.storage;

        let mut reversed_note_hashes = [NoteHashContext::empty(); 10];
        let mut reversed_nullifiers = [Nullifier::empty(); 10];

        for i in 0..10 {
            reversed_note_hashes[9 - i] = builder.previous_kernel.new_note_hashes.pop();
            reversed_nullifiers[9 - i] = builder.previous_kernel.new_nullifiers.pop();
        }

        builder.previous_kernel.new_note_hashes.extend_from_array(reversed_note_hashes);
        builder.previous_kernel.new_nullifiers.extend_from_array(reversed_nullifiers);

        let sorted_unique_note_hashes = builder.compute_unique_siloed_note_hashes(sorted_note_hashes);

        let public_inputs = builder.execute();

        for i in 0..10 {
            assert(public_inputs.end.new_note_hashes[i].eq(sorted_unique_note_hashes[i]));
            assert(public_inputs.end.new_nullifiers[i].eq(sorted_nullifiers[i]));
        }
    }

    #[test(should_fail_with="Hinted note hash does not match")]
    unconstrained fn wrong_transient_nullifier_index_for_note_hash_fails() {
        let mut builder = PrivateKernelTailToPublicInputsBuilder::new();
        builder.previous_kernel.append_new_note_hashes(1);
        builder.previous_kernel.append_new_nullifiers(1);
        // The nullifier at index 1 is nullifying the hash at index 0;
        builder.nullify_pending_note_hash(1, 0);
        // Change the hint to be out of bounds.
        builder.transient_nullifier_indexes_for_note_hashes[0] = 0;
        builder.failed();
    }

    #[test(should_fail_with="Invalid transient nullifier index hint")]
    unconstrained fn wrong_transient_nullifier_index_hint_fails() {
        let mut builder = PrivateKernelTailToPublicInputsBuilder::new();
        builder.previous_kernel.append_new_note_hashes(2);
        builder.previous_kernel.append_new_nullifiers(2);
        // The nullifier at index 1 is nullifying the hash at index 1;
        builder.nullify_pending_note_hash(1, 1);
        // The nullifier at index 2 is nullifying the hash at index 0;
        builder.nullify_pending_note_hash(2, 0);
        // Tweak the hint to be for the hash at index 1.
        builder.transient_note_hash_indexes_for_nullifiers[2] = 1;
        builder.failed();
    }

    #[test(should_fail_with="Private call stack must be empty when executing the tail circuit")]
    unconstrained fn non_empty_private_call_stack_should_fail() {
        let mut builder = PrivateKernelTailToPublicInputsBuilder::new();
        builder.previous_kernel.push_private_call_request(1, false);
        builder.failed();
    }

    #[test(should_fail_with="Public call stack must not be empty when exporting public kernel data from the tail circuit")]
    unconstrained fn empty_public_call_stack_should_fail() {
        let mut builder = PrivateKernelTailToPublicInputsBuilder::new();
        builder.previous_kernel.public_call_stack = BoundedVec::new();
        builder.failed();
    }

    #[test(should_fail_with="The 0th nullifier in the accumulated nullifier array is zero")]
    unconstrained fn zero_0th_nullifier_fails() {
        let mut builder = PrivateKernelTailToPublicInputsBuilder::new();
        builder.previous_kernel.new_nullifiers = BoundedVec::new();
        builder.failed();
    }

    #[test]
    unconstrained fn split_nullifiers_into_non_revertible() {
        let mut builder = PrivateKernelTailToPublicInputsBuilder::new();
        // expect 3 non-revertible nullifiers: the tx nullifier + 2 new ones
        builder.previous_kernel.append_new_nullifiers(2);
        builder.previous_kernel.end_setup();

        // expect 2 revertible nullifiers
        builder.previous_kernel.append_new_nullifiers(2);

        let new_nullifiers = builder.previous_kernel.new_nullifiers.storage;
        let public_inputs = builder.execute();

        assert(
            array_eq(
                public_inputs.end_non_revertible.new_nullifiers,
                [new_nullifiers[0], new_nullifiers[1], new_nullifiers[2]]
            )
        );

        assert(
            array_eq(
                public_inputs.end.new_nullifiers,
                [new_nullifiers[3], new_nullifiers[4]]
            )
        );

        assert_eq(public_inputs.end.gas_used, Gas::new(2 * DA_BYTES_PER_FIELD * DA_GAS_PER_BYTE, 0));
        assert_eq(
            public_inputs.end_non_revertible.gas_used, Gas::new(3 * DA_BYTES_PER_FIELD * DA_GAS_PER_BYTE, 0) + Gas::tx_overhead()
        );
    }

    #[test]
    unconstrained fn split_note_hashes_into_non_revertible() {
        let mut builder = PrivateKernelTailToPublicInputsBuilder::new();

        // expect 2 non-revertible note hashes
        builder.previous_kernel.append_new_note_hashes(2);
        builder.previous_kernel.end_setup();

        // expect 2 revertible note hashes
        builder.previous_kernel.append_new_note_hashes(2);

        let new_note_hashes = builder.previous_kernel.new_note_hashes.storage;
        let public_inputs = builder.execute();

        let siloed_note_hashes = builder.compute_unique_siloed_note_hashes(new_note_hashes);

        assert(
            array_eq(
                public_inputs.end_non_revertible.new_note_hashes,
                [siloed_note_hashes[0], siloed_note_hashes[1]]
            )
        );

        assert(
            array_eq(
                public_inputs.end.new_note_hashes,
                [siloed_note_hashes[2], siloed_note_hashes[3]]
            )
        );
    }

    #[test]
    unconstrained fn split_side_effect_squashing() {
        let mut builder = PrivateKernelTailToPublicInputsBuilder::new();

        // add one hash in non-revertible part
        builder.previous_kernel.append_new_note_hashes(1);
        builder.previous_kernel.end_setup();

        // nullify it in revertible part
        builder.previous_kernel.append_new_nullifiers(1);
        builder.nullify_pending_note_hash(1, 0);

        let public_inputs = builder.execute();

        assert(!is_empty_array(public_inputs.end_non_revertible.new_nullifiers));
        assert(is_empty_array(public_inputs.end_non_revertible.new_note_hashes));
        assert(is_empty_array(public_inputs.end.new_note_hashes));
        assert(is_empty_array(public_inputs.end.new_nullifiers));
    }

    #[test]
    unconstrained fn empty_tx_consumes_teardown_limits_plus_fixed_gas() {
        let mut builder = PrivateKernelTailToPublicInputsBuilder::new();
        builder.previous_kernel.tx_context.gas_settings.teardown_gas_limits = Gas::new(300, 300);
        let public_inputs = builder.execute();

        let expected_gas_consumed = Gas::new(300, 300) + Gas::tx_overhead();
        assert_eq(public_inputs.end.gas_used, expected_gas_consumed);
    }

    #[test(should_fail_with="The gas used exceeds the gas limits")]
    unconstrained fn gas_limits_are_enforced() {
        let mut builder = PrivateKernelTailToPublicInputsBuilder::new();
        builder.previous_kernel.tx_context.gas_settings.teardown_gas_limits = Gas::new(300, 300);
        builder.previous_kernel.tx_context.gas_settings.gas_limits = Gas::new(1, 1);
        builder.failed();
    }
}

use dep::aztec::{
    prelude::{AztecAddress, NoteHeader, NoteInterface, PrivateContext, emit_encrypted_log},
    protocol_types::constants::GENERATOR_INDEX__NOTE_NULLIFIER,
    note::utils::compute_note_hash_for_consumption, hash::poseidon2_hash,
    oracle::{unsafe_rand::unsafe_rand, nullifier_key::get_app_nullifier_secret_key, get_public_key::get_public_key}
};

trait OwnedNote {
    fn new(amount: U128, owner: AztecAddress) -> Self;
    fn get_amount(self) -> U128;
    fn get_owner(self) -> AztecAddress;
}

global TOKEN_NOTE_LEN: Field = 3; // 3 plus a header.

#[aztec(note)]
struct TokenNote {
    // the amount of tokens in the note
    amount: U128,
    // the provider of secrets for the nullifier. The owner (recipient) to ensure that the note 
    // can be privately spent. When nullifier secret and encryption private key is same 
    // we can simply use the owner for this one.
    owner: AztecAddress,
    // randomness of the note to hide contents.
    randomness: Field,
}

impl NoteInterface<TOKEN_NOTE_LEN> for TokenNote {
    // docs:start:nullifier
    fn compute_nullifier(self, context: &mut PrivateContext) -> Field {
        let note_hash_for_nullify = compute_note_hash_for_consumption(self);
        let secret = context.request_app_nullifier_secret_key(self.owner);
        poseidon2_hash([
            note_hash_for_nullify,
            secret,
            GENERATOR_INDEX__NOTE_NULLIFIER as Field,
        ])
    }
    // docs:end:nullifier

    fn compute_nullifier_without_context(self) -> Field {
        let note_hash_for_nullify = compute_note_hash_for_consumption(self);
        let secret = get_app_nullifier_secret_key(self.owner);
        poseidon2_hash([
            note_hash_for_nullify,
            secret,
            GENERATOR_INDEX__NOTE_NULLIFIER as Field,
        ])
    }

    // Broadcasts the note as an encrypted log on L1.
    fn broadcast(self, context: &mut PrivateContext, slot: Field) {
      // We only bother inserting the note if non-empty to save funds on gas.
      if !(self.amount == U128::from_integer(0)) {
          let encryption_pub_key = get_public_key(self.owner);
          emit_encrypted_log(
              context,
              (*context).this_address(),
              slot,
              Self::get_note_type_id(),
              encryption_pub_key,
              self.serialize_content(),
          );
      }
    }
}

impl OwnedNote for TokenNote {
    fn new(amount: U128, owner: AztecAddress) -> Self {
        Self {
            amount,
            owner,
            randomness: unsafe_rand(),
            header: NoteHeader::empty(),
        }
    }

    fn get_amount(self) -> U128 {
        self.amount
    }

    fn get_owner(self) -> AztecAddress {
        self.owner
    }
}

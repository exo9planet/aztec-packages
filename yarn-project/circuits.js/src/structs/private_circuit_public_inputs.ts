import { makeTuple } from '@aztec/foundation/array';
import { isArrayEmpty } from '@aztec/foundation/collection';
import { pedersenHash } from '@aztec/foundation/crypto';
import { Fr } from '@aztec/foundation/fields';
import {
  BufferReader,
  FieldReader,
  type Tuple,
  serializeToBuffer,
  serializeToFields,
} from '@aztec/foundation/serialize';
import { type FieldsOf } from '@aztec/foundation/types';

import {
  GeneratorIndex,
  MAX_ENCRYPTED_LOGS_PER_CALL,
  MAX_NEW_L2_TO_L1_MSGS_PER_CALL,
  MAX_NEW_NOTE_HASHES_PER_CALL,
  MAX_NEW_NULLIFIERS_PER_CALL,
  MAX_NOTE_HASH_READ_REQUESTS_PER_CALL,
  MAX_NULLIFIER_KEY_VALIDATION_REQUESTS_PER_CALL,
  MAX_NULLIFIER_READ_REQUESTS_PER_CALL,
  MAX_PRIVATE_CALL_STACK_LENGTH_PER_CALL,
  MAX_PUBLIC_CALL_STACK_LENGTH_PER_CALL,
  MAX_UNENCRYPTED_LOGS_PER_CALL,
  PRIVATE_CIRCUIT_PUBLIC_INPUTS_LENGTH,
} from '../constants.gen.js';
import { Header } from '../structs/header.js';
import { isEmptyArray } from '../utils/index.js';
import { CallContext } from './call_context.js';
import { L2ToL1Message } from './l2_to_l1_message.js';
import { MaxBlockNumber } from './max_block_number.js';
import { NoteHash } from './note_hash.js';
import { Nullifier } from './nullifier.js';
import { NullifierKeyValidationRequest } from './nullifier_key_validation_request.js';
import { ReadRequest } from './read_request.js';
import { SideEffect } from './side_effects.js';
import { TxContext } from './tx_context.js';

/**
 * Public inputs to a private circuit.
 * @see abis/private_circuit_public_inputs.hpp.
 */
export class PrivateCircuitPublicInputs {
  constructor(
    /**
     * Context of the call corresponding to this private circuit execution.
     */
    public callContext: CallContext,
    /**
     * Pedersen hash of function arguments.
     */
    public argsHash: Fr,
    /**
     * Pedersen hash of the return values of the corresponding function call.
     */
    public returnsHash: Fr,
    /**
     * The side-effect counter under which all side effects are non-revertible.
     */
    public minRevertibleSideEffectCounter: Fr,
    /**
     * The maximum block number in which this transaction can be included and be valid.
     */
    public maxBlockNumber: MaxBlockNumber,
    /**
     * Read requests created by the corresponding function call.
     */
    public noteHashReadRequests: Tuple<SideEffect, typeof MAX_NOTE_HASH_READ_REQUESTS_PER_CALL>,
    /**
     * Nullifier read requests created by the corresponding function call.
     */
    public nullifierReadRequests: Tuple<ReadRequest, typeof MAX_NULLIFIER_READ_REQUESTS_PER_CALL>,
    /**
     * Nullifier key validation requests created by the corresponding function call.
     */
    public nullifierKeyValidationRequests: Tuple<
      NullifierKeyValidationRequest,
      typeof MAX_NULLIFIER_KEY_VALIDATION_REQUESTS_PER_CALL
    >,
    /**
     * New note hashes created by the corresponding function call.
     */
    public newNoteHashes: Tuple<NoteHash, typeof MAX_NEW_NOTE_HASHES_PER_CALL>,
    /**
     * New nullifiers created by the corresponding function call.
     */
    public newNullifiers: Tuple<Nullifier, typeof MAX_NEW_NULLIFIERS_PER_CALL>,
    /**
     * Private call stack at the current kernel iteration.
     */
    public privateCallStackHashes: Tuple<Fr, typeof MAX_PRIVATE_CALL_STACK_LENGTH_PER_CALL>,
    /**
     * Public call stack at the current kernel iteration.
     */
    public publicCallStackHashes: Tuple<Fr, typeof MAX_PUBLIC_CALL_STACK_LENGTH_PER_CALL>,
    /**
     * New L2 to L1 messages created by the corresponding function call.
     */
    public newL2ToL1Msgs: Tuple<L2ToL1Message, typeof MAX_NEW_L2_TO_L1_MSGS_PER_CALL>,
    /**
     * The side effect counter at the start of this call.
     */
    public startSideEffectCounter: Fr,
    /**
     * The end side effect counter for this call.
     */
    public endSideEffectCounter: Fr,
    /**
     * Hash of the encrypted logs emitted in this function call.
     * Note: Truncated to 31 bytes to fit in Fr.
     */
    public encryptedLogsHashes: Tuple<SideEffect, typeof MAX_ENCRYPTED_LOGS_PER_CALL>,
    /**
     * Hash of the unencrypted logs emitted in this function call.
     * Note: Truncated to 31 bytes to fit in Fr.
     */
    public unencryptedLogsHashes: Tuple<SideEffect, typeof MAX_UNENCRYPTED_LOGS_PER_CALL>,
    /**
     * Length of the encrypted log preimages emitted in this function call.
     * Note: Here so that the gas cost of this request can be measured by circuits, without actually needing to feed
     *       in the variable-length data.
     */
    public encryptedLogPreimagesLength: Fr,
    /**
     * Length of the unencrypted log preimages emitted in this function call.
     */
    public unencryptedLogPreimagesLength: Fr,
    /**
     * Header of a block whose state is used during private execution (not the block the transaction is included in).
     */
    public historicalHeader: Header,
    /**
     * Transaction context.
     *
     * Note: The chainId and version in the txContext are not redundant to the values in self.historical_header.global_variables because
     * they can be different in case of a protocol upgrade. In such a situation we could be using header from a block
     * before the upgrade took place but be using the updated protocol to execute and prove the transaction.
     */
    public txContext: TxContext,
  ) {}

  /**
   * Create PrivateCircuitPublicInputs from a fields dictionary.
   * @param fields - The dictionary.
   * @returns A PrivateCircuitPublicInputs object.
   */
  static from(fields: FieldsOf<PrivateCircuitPublicInputs>): PrivateCircuitPublicInputs {
    return new PrivateCircuitPublicInputs(...PrivateCircuitPublicInputs.getFields(fields));
  }

  /**
   * Deserializes from a buffer or reader.
   * @param buffer - Buffer or reader to read from.
   * @returns The deserialized instance.
   */
  static fromBuffer(buffer: Buffer | BufferReader): PrivateCircuitPublicInputs {
    const reader = BufferReader.asReader(buffer);
    return new PrivateCircuitPublicInputs(
      reader.readObject(CallContext),
      reader.readObject(Fr),
      reader.readObject(Fr),
      reader.readObject(Fr),
      reader.readObject(MaxBlockNumber),
      reader.readArray(MAX_NOTE_HASH_READ_REQUESTS_PER_CALL, SideEffect),
      reader.readArray(MAX_NULLIFIER_READ_REQUESTS_PER_CALL, ReadRequest),
      reader.readArray(MAX_NULLIFIER_KEY_VALIDATION_REQUESTS_PER_CALL, NullifierKeyValidationRequest),
      reader.readArray(MAX_NEW_NOTE_HASHES_PER_CALL, NoteHash),
      reader.readArray(MAX_NEW_NULLIFIERS_PER_CALL, Nullifier),
      reader.readArray(MAX_PRIVATE_CALL_STACK_LENGTH_PER_CALL, Fr),
      reader.readArray(MAX_PUBLIC_CALL_STACK_LENGTH_PER_CALL, Fr),
      reader.readArray(MAX_NEW_L2_TO_L1_MSGS_PER_CALL, L2ToL1Message),
      reader.readObject(Fr),
      reader.readObject(Fr),
      reader.readArray(MAX_ENCRYPTED_LOGS_PER_CALL, SideEffect),
      reader.readArray(MAX_UNENCRYPTED_LOGS_PER_CALL, SideEffect),
      reader.readObject(Fr),
      reader.readObject(Fr),
      reader.readObject(Header),
      reader.readObject(TxContext),
    );
  }

  static fromFields(fields: Fr[] | FieldReader): PrivateCircuitPublicInputs {
    const reader = FieldReader.asReader(fields);
    return new PrivateCircuitPublicInputs(
      reader.readObject(CallContext),
      reader.readField(),
      reader.readField(),
      reader.readField(),
      reader.readObject(MaxBlockNumber),
      reader.readArray(MAX_NOTE_HASH_READ_REQUESTS_PER_CALL, SideEffect),
      reader.readArray(MAX_NULLIFIER_READ_REQUESTS_PER_CALL, ReadRequest),
      reader.readArray(MAX_NULLIFIER_KEY_VALIDATION_REQUESTS_PER_CALL, NullifierKeyValidationRequest),
      reader.readArray(MAX_NEW_NOTE_HASHES_PER_CALL, NoteHash),
      reader.readArray(MAX_NEW_NULLIFIERS_PER_CALL, Nullifier),
      reader.readFieldArray(MAX_PRIVATE_CALL_STACK_LENGTH_PER_CALL),
      reader.readFieldArray(MAX_PUBLIC_CALL_STACK_LENGTH_PER_CALL),
      reader.readArray(MAX_NEW_L2_TO_L1_MSGS_PER_CALL, L2ToL1Message),
      reader.readField(),
      reader.readField(),
      reader.readArray(MAX_ENCRYPTED_LOGS_PER_CALL, SideEffect),
      reader.readArray(MAX_UNENCRYPTED_LOGS_PER_CALL, SideEffect),
      reader.readField(),
      reader.readField(),
      reader.readObject(Header),
      reader.readObject(TxContext),
    );
  }

  /**
   * Create an empty PrivateCircuitPublicInputs.
   * @returns An empty PrivateCircuitPublicInputs object.
   */
  public static empty(): PrivateCircuitPublicInputs {
    return new PrivateCircuitPublicInputs(
      CallContext.empty(),
      Fr.ZERO,
      Fr.ZERO,
      Fr.ZERO,
      MaxBlockNumber.empty(),
      makeTuple(MAX_NOTE_HASH_READ_REQUESTS_PER_CALL, SideEffect.empty),
      makeTuple(MAX_NULLIFIER_READ_REQUESTS_PER_CALL, ReadRequest.empty),
      makeTuple(MAX_NULLIFIER_KEY_VALIDATION_REQUESTS_PER_CALL, NullifierKeyValidationRequest.empty),
      makeTuple(MAX_NEW_NOTE_HASHES_PER_CALL, NoteHash.empty),
      makeTuple(MAX_NEW_NULLIFIERS_PER_CALL, Nullifier.empty),
      makeTuple(MAX_PRIVATE_CALL_STACK_LENGTH_PER_CALL, Fr.zero),
      makeTuple(MAX_PUBLIC_CALL_STACK_LENGTH_PER_CALL, Fr.zero),
      makeTuple(MAX_NEW_L2_TO_L1_MSGS_PER_CALL, L2ToL1Message.empty),
      Fr.ZERO,
      Fr.ZERO,
      makeTuple(MAX_ENCRYPTED_LOGS_PER_CALL, SideEffect.empty),
      makeTuple(MAX_UNENCRYPTED_LOGS_PER_CALL, SideEffect.empty),
      Fr.ZERO,
      Fr.ZERO,
      Header.empty(),
      TxContext.empty(),
    );
  }

  isEmpty() {
    const isZeroArray = (arr: { isZero: (...args: any[]) => boolean }[]) => isArrayEmpty(arr, item => item.isZero());
    return (
      this.callContext.isEmpty() &&
      this.argsHash.isZero() &&
      this.returnsHash.isZero() &&
      this.minRevertibleSideEffectCounter.isZero() &&
      this.maxBlockNumber.isEmpty() &&
      isEmptyArray(this.noteHashReadRequests) &&
      isEmptyArray(this.nullifierReadRequests) &&
      isEmptyArray(this.nullifierKeyValidationRequests) &&
      isEmptyArray(this.newNoteHashes) &&
      isEmptyArray(this.newNullifiers) &&
      isZeroArray(this.privateCallStackHashes) &&
      isZeroArray(this.publicCallStackHashes) &&
      isEmptyArray(this.newL2ToL1Msgs) &&
      isEmptyArray(this.encryptedLogsHashes) &&
      isEmptyArray(this.unencryptedLogsHashes) &&
      this.encryptedLogPreimagesLength.isZero() &&
      this.unencryptedLogPreimagesLength.isZero() &&
      this.historicalHeader.isEmpty() &&
      this.txContext.isEmpty()
    );
  }

  /**
   * Serialize into a field array. Low-level utility.
   * @param fields - Object with fields.
   * @returns The array.
   */
  static getFields(fields: FieldsOf<PrivateCircuitPublicInputs>) {
    return [
      fields.callContext,
      fields.argsHash,
      fields.returnsHash,
      fields.minRevertibleSideEffectCounter,
      fields.maxBlockNumber,
      fields.noteHashReadRequests,
      fields.nullifierReadRequests,
      fields.nullifierKeyValidationRequests,
      fields.newNoteHashes,
      fields.newNullifiers,
      fields.privateCallStackHashes,
      fields.publicCallStackHashes,
      fields.newL2ToL1Msgs,
      fields.startSideEffectCounter,
      fields.endSideEffectCounter,
      fields.encryptedLogsHashes,
      fields.unencryptedLogsHashes,
      fields.encryptedLogPreimagesLength,
      fields.unencryptedLogPreimagesLength,
      fields.historicalHeader,
      fields.txContext,
    ] as const;
  }

  /**
   * Serialize this as a buffer.
   * @returns The buffer.
   */
  toBuffer(): Buffer {
    return serializeToBuffer(...PrivateCircuitPublicInputs.getFields(this));
  }

  /**
   * Serialize this as a field array.
   */
  toFields(): Fr[] {
    const fields = serializeToFields(...PrivateCircuitPublicInputs.getFields(this));
    if (fields.length !== PRIVATE_CIRCUIT_PUBLIC_INPUTS_LENGTH) {
      throw new Error(
        `Invalid number of fields for PrivateCircuitPublicInputs. Expected ${PRIVATE_CIRCUIT_PUBLIC_INPUTS_LENGTH}, got ${fields.length}`,
      );
    }
    return fields;
  }

  hash(): Fr {
    return pedersenHash(this.toFields(), GeneratorIndex.PRIVATE_CIRCUIT_PUBLIC_INPUTS);
  }
}

import { type EncryptedFunctionL2Logs, type Note, type UnencryptedFunctionL2Logs } from '@aztec/circuit-types';
import {
  type NoteHashReadRequestMembershipWitness,
  type PrivateCallStackItem,
  type PublicCallRequest,
} from '@aztec/circuits.js';
import { type Fr } from '@aztec/foundation/fields';

import { type ACVMField } from '../acvm/index.js';

/**
 * The contents of a new note.
 */
export interface NoteAndSlot {
  /** The note. */
  note: Note;
  /** The storage slot of the note. */
  storageSlot: Fr;
  /** The note type identifier. */
  noteTypeId: Fr;
}

export interface NullifiedNoteHashCounter {
  noteHashCounter: number;
  nullifierCounter: number;
}

/**
 * The result of executing a private function.
 */
export interface ExecutionResult {
  // Needed for prover
  /** The ACIR bytecode. */
  acir: Buffer;
  /** The verification key. */
  vk: Buffer;
  /** The partial witness. */
  partialWitness: Map<number, ACVMField>;
  // Needed for the verifier (kernel)
  /** The call stack item. */
  callStackItem: PrivateCallStackItem;
  /** The partially filled-in read request membership witnesses for commitments being read. */
  noteHashReadRequestPartialWitnesses: NoteHashReadRequestMembershipWitness[];
  /** The notes created in the executed function. */
  newNotes: NoteAndSlot[];
  nullifiedNoteHashCounters: NullifiedNoteHashCounter[];
  /** The raw return values of the executed function. */
  returnValues: Fr[];
  /** The nested executions. */
  nestedExecutions: this[];
  /** Enqueued public function execution requests to be picked up by the sequencer. */
  enqueuedPublicFunctionCalls: PublicCallRequest[];
  /**
   * Encrypted logs emitted during execution of this function call.
   * Note: These are preimages to `encryptedLogsHashes`.
   */
  encryptedLogs: EncryptedFunctionL2Logs;
  /**
   * Unencrypted logs emitted during execution of this function call.
   * Note: These are preimages to `unencryptedLogsHashes`.
   */
  unencryptedLogs: UnencryptedFunctionL2Logs;
}

export function collectNullifiedNoteHashCounters(execResult: ExecutionResult): NullifiedNoteHashCounter[] {
  return [
    execResult.nullifiedNoteHashCounters,
    ...execResult.nestedExecutions.flatMap(collectNullifiedNoteHashCounters),
  ].flat();
}

/**
 * Collect all encrypted logs across all nested executions.
 * @param execResult - The topmost execution result.
 * @returns All encrypted logs.
 */
export function collectEncryptedLogs(execResult: ExecutionResult): EncryptedFunctionL2Logs[] {
  // without the .reverse(), the logs will be in a queue like fashion which is wrong as the kernel processes it like a stack.
  return [execResult.encryptedLogs, ...[...execResult.nestedExecutions].reverse().flatMap(collectEncryptedLogs)];
}

/**
 * Collect all unencrypted logs across all nested executions.
 * @param execResult - The topmost execution result.
 * @returns All unencrypted logs.
 */
export function collectUnencryptedLogs(execResult: ExecutionResult): UnencryptedFunctionL2Logs[] {
  // without the .reverse(), the logs will be in a queue like fashion which is wrong as the kernel processes it like a stack.
  return [execResult.unencryptedLogs, ...[...execResult.nestedExecutions].reverse().flatMap(collectUnencryptedLogs)];
}

/**
 * Collect all enqueued public function calls across all nested executions.
 * @param execResult - The topmost execution result.
 * @returns All enqueued public function calls.
 */
export function collectEnqueuedPublicFunctionCalls(execResult: ExecutionResult): PublicCallRequest[] {
  // without the reverse sort, the logs will be in a queue like fashion which is wrong
  // as the kernel processes it like a stack, popping items off and pushing them to output
  return [
    ...execResult.enqueuedPublicFunctionCalls,
    ...[...execResult.nestedExecutions].flatMap(collectEnqueuedPublicFunctionCalls),
  ].sort((a, b) => b.callContext.sideEffectCounter - a.callContext.sideEffectCounter);
}

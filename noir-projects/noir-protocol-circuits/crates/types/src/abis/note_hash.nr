use crate::{
    address::AztecAddress, abis::side_effect::{Ordered, OrderedValue},
    constants::{NOTE_HASH_LENGTH, NOTE_HASH_CONTEXT_LENGTH}, traits::{Empty, Serialize, Deserialize}
};
use dep::std::cmp::Eq;

struct NoteHash {
    value: Field,
    counter: u32,
}

impl Ordered for NoteHash {
    fn counter(self) -> u32 {
        self.counter
    }
}

impl OrderedValue<Field> for NoteHash {
    fn value(self) -> Field {
        self.value
    }
    fn counter(self) -> u32 {
        self.counter
    }
}

impl Eq for NoteHash {
    fn eq(self, other: NoteHash) -> bool {
        (self.value == other.value)
            & (self.counter == other.counter) 
    }
}

impl Empty for NoteHash {
    fn empty() -> Self {
        NoteHash {
            value: 0,
            counter: 0,
        }
    }
}

impl Serialize<NOTE_HASH_LENGTH> for NoteHash {
    fn serialize(self) -> [Field; NOTE_HASH_LENGTH] {
        [self.value, self.counter as Field]
    }
}

impl Deserialize<NOTE_HASH_LENGTH> for NoteHash {
    fn deserialize(values: [Field; NOTE_HASH_LENGTH]) -> Self {
        Self {
            value: values[0],
            counter: values[1] as u32,
        }
    }
}

impl NoteHash {
    pub fn to_context(self, nullifier_counter: u32) -> NoteHashContext {
        NoteHashContext { value: self.value, counter: self.counter, nullifier_counter }
    }
}

struct NoteHashContext {
    value: Field,
    counter: u32,
    nullifier_counter: u32,
}

impl Ordered for NoteHashContext {
    fn counter(self) -> u32 {
        self.counter
    }
}

impl OrderedValue<Field> for NoteHashContext {
    fn value(self) -> Field {
        self.value
    }
    fn counter(self) -> u32 {
        self.counter
    }
}

impl Eq for NoteHashContext {
    fn eq(self, other: NoteHashContext) -> bool {
        (self.value == other.value)
            & (self.counter == other.counter) 
            & (self.nullifier_counter == other.nullifier_counter)
    }
}

impl Empty for NoteHashContext {
    fn empty() -> Self {
        NoteHashContext {
            value: 0,
            counter: 0,
            nullifier_counter: 0,
        }
    }
}

impl Serialize<NOTE_HASH_CONTEXT_LENGTH> for NoteHashContext {
    fn serialize(self) -> [Field; NOTE_HASH_CONTEXT_LENGTH] {
        [self.value, self.counter as Field, self.nullifier_counter as Field]
    }
}

impl Deserialize<NOTE_HASH_CONTEXT_LENGTH> for NoteHashContext {
    fn deserialize(values: [Field; NOTE_HASH_CONTEXT_LENGTH]) -> Self {
        Self {
            value: values[0],
            counter: values[1] as u32,
            nullifier_counter: values[2] as u32,
        }
    }
}

impl NoteHashContext {
    pub fn to_note_hash(self) -> NoteHash {
        NoteHash { value: self.value, counter: self.counter }
    }

    pub fn expose_to_public(self) -> NoteHash {
        // Hide the actual counter when exposing it to the public kernel.
        NoteHash { value: self.value, counter: 0 }
    }
}

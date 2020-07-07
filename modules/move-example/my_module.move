address 0x0000000000000000000000000a550c18:

module MyModule {
  use 0x0::Libra;
  use 0x0::LBR;
  use 0x0::Event;

	struct DummyEvent { 
			b: bool 
	}

	public fun emit_event(val: bool) {
			let handle: Event::EventHandle<Self::DummyEvent>;
			handle = Event::new_event_handle<Self::DummyEvent>();
			Event::emit_event<Self::DummyEvent>(&mut handle, DummyEvent{ b: val });
			Event::destroy_handle<Self::DummyEvent>(handle);
	}

  // The identity function: takes a Libra::T<LBR::T> as input and hands it back
  public fun id(c: Libra::T<LBR::T>): Libra::T<LBR::T> {
		emit_event(true);
    c
  }
}
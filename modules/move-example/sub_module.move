address 0x0000000000000000000000000a550c18:

module MySubModule {
  use 0x0::Libra;
  use 0x0::LBR;
  use 0x0000000000000000000000000a550c18::MyModule;

  // The identity function: takes a Libra::T<LBR::T> as input and hands it back
  public fun test(c: Libra::T<LBR::T>): Libra::T<LBR::T> {
    MyModule::id(c)
  }
}
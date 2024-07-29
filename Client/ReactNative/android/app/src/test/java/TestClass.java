
public class TestClass {
  public static final TestClass Foo = new TestClass("foo");
  public static final TestClass bar = new TestClass("foo");

  public final String mask;

  TestClass(String mask) {
    this.mask = mask;
  }
}


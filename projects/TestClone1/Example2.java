public class Example2 {
    public void g () {
        int a=0;
        int b=1;
        int w=2;
        // int d=4;
        int s=4;
    }

    private void e ()
    {
        String s = "Hello";
    }

    public static void main(String[] args) {
        if(args.length > 0) {
            greetUser("Alice");
            int x=0;
            int a=1;
            int b=2;
            int w=4;
        }
    }

    // Method to greet a user
    public static void greetUser(String name) {
        System.out.println("Hello, " + name + "!");
    }
}
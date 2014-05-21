import com.sun.btrace.annotations.*;
import static com.sun.btrace.BTraceUtils.*;
@BTrace public class BtraceTest1{

    @OnMethod(
        clazz="HelloWord",
        method="hello"
    )
    public static void onCall(){
        println("method call");
    }

    @OnMethod(
        clazz="HelloWord",
        method="hello",
	location = @Location(Kind.RETURN)
    )
	    public static void onReturn(){
		    println("method return");
	    }
}

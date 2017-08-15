module Utils

using Jute


pprint_time_test = testcase() do
    # normal operation for large times
    @test pprint_time(32 * 24 * 3600 + 12 * 3600 + 6 * 60 + 7) == "32d 12h 6m 7s"
    @test pprint_time(12 * 3600 + 6 * 60 + 7) == "12h 6m 7s"
    @test pprint_time(6 * 60 + 7) == "6m 7s"
    @test pprint_time(7) == "7s"

    # some units are skipped
    @test pprint_time(32 * 24 * 3600 + 6 * 60) == "32d 6m"

    # exact time below 1 minute
    @test pprint_time(55.345, meaningful_digits=3) == "55.3s"
    @test pprint_time(55, meaningful_digits=3) == "55.0s"

    # exact time above 1 minute - falls back to large times
    @test pprint_time(65, meaningful_digits=3) == "1m 5s"

    # normal operation for small times
    @test pprint_time(55.345 * 1e-3, meaningful_digits=3) == "55.3ms"
    @test pprint_time(55.345 * 1e-6, meaningful_digits=3) == "55.3us"
    @test pprint_time(55.345 * 1e-9, meaningful_digits=3) == "55.3ns"
    @test pprint_time(55.345 * 1e-12, meaningful_digits=3) == "0.0553ns"

    # small times with meaningful_digts==0 (default)
    @test pprint_time(55.345 * 1e-3) == "55ms"
end


rowmajor_product_test = testcase() do
    @test collect(rowmajor_product()) == [()]
    @test collect(rowmajor_product(1:2)) == [(1,), (2,)]
    @test collect(rowmajor_product(1:2, [])) == []
    @test collect(rowmajor_product(1:2, 3:4)) == [(1, 3), (1, 4), (2, 3), (2, 4)]
end


# Output redirection hangs on Windows and Julia 0.6, see Julia issue 23198
# Temporarily disabling these tests.
if !(Sys.is_windows() && Base.thisminor(VERSION) < v"0.7")
    # Check that if pass_through=true, the output is not captured
    pass_through = testcase() do
        # In order to see that the output is not captured,
        # we still need to capture it one level higher.
        with_output_capture() do
            ret, out = with_output_capture(true) do
                println(STDOUT, "stdout 1")
                println(STDERR, "stderr 1")
                1
            end

            @test ret == 1
            @test out == ""
        end
    end


    # Check that both STDOUT and STDERR are captured and joined in the correct order
    capture_all = testcase() do
        ret, out = with_output_capture() do
            println(STDOUT, "stdout 1")
            println(STDERR, "stderr 1")
            println(STDOUT, "stdout 2")
            println(STDERR, "stderr 2")
            1
        end

        @test ret == 1
        @test out == "stdout 1\nstderr 1\nstdout 2\nstderr 2\n"
    end


    # Check that the handles are restored to previous values
    # if an exception is thrown in the function.
    restore_on_error = testcase() do
        try
            with_output_capture() do
                println(STDOUT, "stdout 1")
                println(STDERR, "stderr 1")
                error("error")
                1
            end
        catch e
            @test isa(e, ErrorException)
        end

        # TODO: how do we check that the output is back to normal?
        # (besides eyeballing the test output, of course)
    end
end


end

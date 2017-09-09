using TestUtils


@testgroup "reporting" begin


TESTCASES = Jute.collect_testobjs() do
    @testcase "multiple tests" begin
        @test 1 == 1
        @test 2 == 2
        @test 3 == 3
    end

    @testcase "returning value" begin
        @test 1 == 1
        @test_result 10
    end

    @testcase "multiple tests and one failure" begin
        @test 1 == 1
        @test 2 == 1
        @test 3 == 3
    end

    @testcase "uncaught exception" begin
        @test 1 == 1
        error("Uncaught exception")
        @test 1 == 1
    end

    @testcase "caught exception" begin
        @test 1 == 1
        @test_throws ErrorException error("Caught exception")
        @test 1 == 1
    end

    @testcase "skip test" begin
        @test 1 == 1
        @test_skip 1 == 2
        @test 1 == 1
    end

    @testcase "expected failure" begin
        @test 1 == 1
        @test_broken 1 == 2
        @test 1 == 1
    end

    @testcase "unexpected pass" begin
        @test 1 == 1
        @test_broken 1 == 1
        @test 1 == 1
    end

    @testcase "with fixtures" for x in [1], y in [2]
    end

    @testcase "test_fail" begin
        @test_fail "Failure explanation"
    end
end


TESTCASES_WITH_GROUPS = Jute.collect_testobjs() do
    @testcase "root testcase 1" begin end
    @testgroup "group 1" begin
        @testcase "group 1 testcase 1" begin end
        @testcase "group 1 testcase 2" begin end
        @testgroup "subgroup 1" begin
            @testgroup "subsubgroup 1" begin
                @testcase "subsubgroup 1 testcase 1" begin end
                @testcase "subsubgroup 1 testcase 2" begin end
            end
        end
    end
    @testgroup "group 2" begin
        @testcase "group 2 testcase 1" begin end
        @testcase "group 2 testcase 2" begin end
    end
    @testcase "root testcase 2" begin end
end


@testcase "verbosity0" begin
    exitcode, output = nested_run_with_output(TESTCASES, Dict(:verbosity => 0))
    @test exitcode == 1

    template = """
        ================================================================================
        multiple tests and one failure
        Test Failed
          Expression: 2 == 1
           Evaluated: 2 == 1
        ================================================================================
        uncaught exception
        Error During Test
          Got an exception of type ErrorException outside of a @test
          Uncaught exception
          Stacktrace:
        <<<MULTILINE>>>
        ================================================================================
        unexpected pass
        Error During Test
         Unexpected Pass
         Expression: 1 == 1
         Got correct result, please change to @test if no longer broken.

        ================================================================================
        test_fail
        Test Failed
          Failure explanation
    """

    test_match_text(template, output)
end


@testcase "verbosity1" begin
    exitcode, output = nested_run_with_output(TESTCASES, Dict(:verbosity => 1))
    @test exitcode == 1

    template = """
        Collecting testcases...
        Running 10 out of 10 testcases...
        ================================================================================
        Platform: Julia <<<julia_version>>>, Jute <<<jute_version>>>
        --------------------------------------------------------------------------------
        ....*.F..E....B..B..E..F
        --------------------------------------------------------------------------------
        20 tests passed, 2 failed, 2 errored in <<<full_time>>> (total test time <<<test_time>>>)
        ================================================================================
        multiple tests and one failure
        Test Failed
          Expression: 2 == 1
           Evaluated: 2 == 1
        ================================================================================
        uncaught exception
        Error During Test
          Got an exception of type ErrorException outside of a @test
          Uncaught exception
          Stacktrace:
        <<<MULTILINE>>>
        ================================================================================
        unexpected pass
        Error During Test
         Unexpected Pass
         Expression: 1 == 1
         Got correct result, please change to @test if no longer broken.

        ================================================================================
        test_fail
        Test Failed
          Failure explanation
    """

    test_match_text(template, output)
end


@testcase "verbosity2" begin
    exitcode, output = nested_run_with_output(TESTCASES, Dict(:verbosity => 2))
    @test exitcode == 1

    template = """
        Collecting testcases...
        Running 10 out of 10 testcases...
        ================================================================================
        Platform: Julia <<<julia_version>>>, Jute <<<jute_version>>>
        --------------------------------------------------------------------------------
        multiple tests (<<<time>>>) [PASS] [PASS] [PASS]
        returning value (<<<time>>>) [PASS] [10]
        multiple tests and one failure (<<<time>>>) [PASS] [FAIL] [PASS]
        uncaught exception (<<<time>>>) [PASS] [ERROR]
        caught exception (<<<time>>>) [PASS] [PASS] [PASS]
        skip test (<<<time>>>) [PASS] [BROKEN] [PASS]
        expected failure (<<<time>>>) [PASS] [BROKEN] [PASS]
        unexpected pass (<<<time>>>) [PASS] [ERROR] [PASS]
        with fixtures[1,2] (<<<time>>>) [PASS]
        test_fail (<<<time>>>) [FAIL]
        --------------------------------------------------------------------------------
        20 tests passed, 2 failed, 2 errored in <<<full_time>>> (total test time <<<test_time>>>)
        ================================================================================
        multiple tests and one failure
        Test Failed
          Expression: 2 == 1
           Evaluated: 2 == 1
        ================================================================================
        uncaught exception
        Error During Test
          Got an exception of type ErrorException outside of a @test
          Uncaught exception
          Stacktrace:
        <<<MULTILINE>>>
        ================================================================================
        unexpected pass
        Error During Test
         Unexpected Pass
         Expression: 1 == 1
         Got correct result, please change to @test if no longer broken.

        ================================================================================
        test_fail
        Test Failed
          Failure explanation
    """

    test_match_text(template, output)
end


@testcase "verbosity1 with groups" begin
    exitcode, output = nested_run_with_output(TESTCASES_WITH_GROUPS, Dict(:verbosity => 1))
    @test exitcode == 0

    template = """
        Collecting testcases...
        Running 8 out of 8 testcases...
        ================================================================================
        Platform: Julia <<<julia_version>>>, Jute <<<jute_version>>>
        --------------------------------------------------------------------------------
        .
        group 1: ..
          subgroup 1:
            subsubgroup 1: ..
        group 2: ..
        .
        --------------------------------------------------------------------------------
        8 tests passed, 0 failed, 0 errored in <<<full_time>>> (total test time <<<test_time>>>)
    """

    test_match_text(template, output)
end


@testcase "verbosity2 with groups" begin
    exitcode, output = nested_run_with_output(TESTCASES_WITH_GROUPS, Dict(:verbosity => 2))
    @test exitcode == 0

    template = """
        Collecting testcases...
        Running 8 out of 8 testcases...
        ================================================================================
        Platform: Julia <<<julia_version>>>, Jute <<<jute_version>>>
        --------------------------------------------------------------------------------
        root testcase 1 (<<<time>>>) [PASS]
        group 1/
          group 1 testcase 1 (<<<time>>>) [PASS]
          group 1 testcase 2 (<<<time>>>) [PASS]
          subgroup 1/
            subsubgroup 1/
              subsubgroup 1 testcase 1 (<<<time>>>) [PASS]
              subsubgroup 1 testcase 2 (<<<time>>>) [PASS]
        group 2/
          group 2 testcase 1 (<<<time>>>) [PASS]
          group 2 testcase 2 (<<<time>>>) [PASS]
        root testcase 2 (<<<time>>>) [PASS]
        --------------------------------------------------------------------------------
        8 tests passed, 0 failed, 0 errored in <<<full_time>>> (total test time <<<test_time>>>)
    """

    test_match_text(template, output)
end


@testcase "captured_output" begin
    testcases = Jute.collect_testobjs() do
        @testcase "passing testcase" begin
            println(STDOUT, "stdout from passing testcase")
            println(STDERR, "stderr from passing testcase")
        end

        @testcase "failing testcase" begin
            println(STDOUT, "stdout from failing testcase")
            @test 1 == 2
            println(STDERR, "stderr from failing testcase")
        end
    end

    exitcode, output = nested_run_with_output(
        testcases, Dict(:verbosity => 0, :capture_output => true))

    template = """
        ================================================================================
        failing testcase
        Captured output:
        stdout from failing testcase
        stderr from failing testcase

        Test Failed
          Expression: 1 == 2
           Evaluated: 1 == 2
    """

    test_match_text(template, output)
end


end
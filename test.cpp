#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest.h>

#include <vector>

TEST_CASE("test_case")
{
    struct Struct
    {
        std::vector<int> data = {0,1,2};
    };

    Struct s;

    DOCTEST_SUBCASE("a") { }
    DOCTEST_SUBCASE("b") { }
}


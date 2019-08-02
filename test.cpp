#include <vector>

struct Struct
{
    std::vector<int> data{0,1,2};
};

void f()
{
    Struct s;
}

int main()
{
    f();
    f();
    return 0;
}

use Test::Stream -V1, -SpecTesterDeclare;

BEGIN {
    require Test::Stream::Workflow::Meta;
    Test::Stream::Workflow::Meta->build(__PACKAGE__, __FILE__, __LINE__, 'EOF');
}

tests 'a' (skip => undef) {
    is(__LINE__, 9, "Correct line");
}

is(__LINE__, 12, "Correct line");

tests 'b' {
    is(__LINE__, 15, "Correct line");
}

is(__LINE__, 18, "Correct line");

tests c(skip => undef) {
    is(__LINE__, 21, "Correct line");
}

is(__LINE__, 24, "Correct line");

tests d {
    is(__LINE__, 27, "Correct line");
}

is(__LINE__, 30, "Correct line");

tests 'e'
(skip => undef)
{
    is(__LINE__, 35, "Correct line");
}

is(__LINE__, 38, "Correct line");

tests 'f'
{
    is(__LINE__, 42, "Correct line");
}

is(__LINE__, 45, "Correct line");

tests g
(skip => undef)
{
    is(__LINE__, 50, "Correct line");
}

is(__LINE__, 53, "Correct line");

tests d
{
    is(__LINE__, 57, "Correct line");
}

is(__LINE__, 60, "Correct line");

done_testing;

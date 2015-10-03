use Test::Stream -V1, -SpecTesterDeclare;

imported_ok(qw{
    describe    cases       
    tests       it          
    case        
    before_all  after_all  around_all  
    before_case after_case around_case 
    before_each after_each around_each 

    intercept
});

tests foo { ok(1, "parser magic is in place") }

done_testing;

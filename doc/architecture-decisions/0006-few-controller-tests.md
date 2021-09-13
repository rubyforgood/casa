# 1. System tests are preferred over controller tests
Date: 2021-07-14


"system" tests test both the erb and the controller at the same time. They are slower. They use capybara. Having some of these (one per rendered page) is very important because it is possible for a controller to define a variable `@a` and an erb to require a variable `@b` and the tests for the controller and erb to both pass separately, but for the page loading to fail. We need system tests to make sure that our codebase is working properly. 

In general, we don't write many controller tests because they tend to rely overly on mocking and are fully duplicitive with the system tests. 



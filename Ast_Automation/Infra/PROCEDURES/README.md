# TestRunner 
Test Runner to work correctly and efficiently we need to understand the configuration and the flow of the configuration.
1. Test Runner main configuration.
   <BR>This is a simple txt file(default ```test_runner.txt``` that resides in the ```<COSMOS-Project>``` directory's ```config/tools/test_runner folder/```
   <BR>e.g. ```c:\cosmos\ast-chained\config\tools\test_runner\test_runner.txt```
   <BR> This file has following directive.
   ```
   LOAD_UTILITY '<name of the ruby script(without the file extention) containing TestSuite to load>'
   e.g. LOAD_UTILITY 'test_runner_main'
   ```
   You can have multiple of these ```LOAD_UTILITY``` to load more than one TestSuite
2. TestSuite Script must extend from ```COSMOS::TestSuite``` and it can have it's own ```setup``` and ```teardown``` methods.
   <BR>
3. 
 
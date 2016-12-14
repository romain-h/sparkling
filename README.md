# Sparkling - Eslint Vim plugin aerated

The motivation to start a new syntax checker plugin is to leverage latest
api in Vim 8 to run command in background (e.g asynchronously). This cut my
daily 2sec delay on each save.

```

 [{"ruleId":"no-unused-vars","severity":2,"message":"'apero' is defined but never used.","line":7,"colu
 mn":7,"nodeType":"Identifier","source":"const apero = 123;"},{"ruleId":"prefer-const","severity":1,"message":"'history' is never reassigned. Use 'const' instead.","lin
 e":8,"column":5,"nodeType":"Identifier","source":"let history = createBrowserHistory();","fix":{"range":[242,245],"text":"const"}},{"ruleId":"no-unused-vars","severity ":2,"message":"'aa' is defined but never "used.","line":10,"column":7,"nodeType":"Identifier","source":"const aa = 'i';"}

```


Look at vim-easy-align for test  with vader

Functional style: Deepcopy

Difficulties around reloading a program
Autoload + silent!

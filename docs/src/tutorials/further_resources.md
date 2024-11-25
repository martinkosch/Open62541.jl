# Further resources

The tutorials and documentation currently included with Open62541.jl is very slim
(pull request welcome!). This will be gradually improved over time. Meanwhile, it
is important to realize that other resources exist that can be helpful in answering
questions.

## Tutorials in the open62541 documentation

The [tutorials of the open62541 C-library](https://www.open62541.org/doc/master/tutorials.html),
as well as its documentation, are a good starting point. While the code in these
tutorials is of course written in C, many of the function names and approaches
directly transfer over to Open62541.jl and are thus very useful to know.

## Examples in the open62541 source repository on Github

The [examples](https://github.com/open62541/open62541/tree/master/examples) provided in Github repository of the open62541 C-library can also be instructive. Many of the tests of the Julia library have been adapted from examples found in this folder, so it is useful to compare the two codes against each other.

## Tests in Open62541.jl

Code changes implemented in Open62541.jl are continuously tested against a growing
[set of tests](https://github.com/martinkosch/Open62541.jl/tree/main/test). In the absence of more step-by-step guidance, the code for these test sets can be instructive.

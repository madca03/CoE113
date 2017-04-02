1. Copy standard cell libraries to ./lib directory
2. Copy synthesized files to ./mapped directory
3. Copy RTL files to ./rtl directory
4. Edit ./scripts/dep_syn.f to reflect your own synthesized files
5. Edit ./scripts/dep_rtl.f to reflect your own RTL files
6. Go to the ./sim directory (cd ./sim)
7. Run the appropriate test script
 7.a For synthesized test:
     source ../scripts/test_syn.sh
 7.b For RTL test:
     source ../scripts/test_rtl.sh

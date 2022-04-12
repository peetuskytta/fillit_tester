# fillit_tester

This is a tester for the 42 School's fillit project.

## Where to start?

Run this command in your fillit folder:

```git clone https://github.com/peetuskytta/fillit_tester.git```

## How to run it?

Run the tester **in the `fillit_tester`-folder** with the following command:

`./run_fillit_tester.sh`

IMPORTANT! 
- It is recommended to use terminal to run this tester.
- Make sure you have compiled your program before running the script.
- The test files were written with Vim (this is important for VSC users, `\n` might be needed.)

<img width="300" alt="Screen Shot 2022-03-10 at 17 11 27" src="https://user-images.githubusercontent.com/77061872/157691714-c20ccb62-afd7-47c6-9d02-1bbd0cf3b352.png">

After exiting the program you can check errors or memoryleaks in `results/`.

<img width="300" alt="Screen Shot 2022-03-10 at 17 13 48" src="https://user-images.githubusercontent.com/77061872/157692225-c6ea7a6e-9c3e-4b11-b727-d40fe23149aa.png">

### Bugs? Suggestions?

Please inform about issues/bugs. Always open for suggestions of new ideas and tests.

### Future Features?:

- [ ] diff to speed testing maps
- [ ] Documenting the `run_fillit_tester.sh` script for better understanding on what's going on.
- [ ] Option to run the program in less/more information mode (e.g: show each valid map expected and test result)
- [ ] Add Norm checking
- [ ] Add author checker
- [ ] Add over 27 piece memory leak test
- [ ] Create a tetrimino generator

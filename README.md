# Prog-6a
MASM - Program 6a - Computer Architecture and Assembly Language

Objectives:
  1) Designing, implementing, and calling low-level I/O procedures
  2) Implementing and using a macro
Problem Definition:
  • Implement and test your own ReadVal and WriteVal procedures for unsigned integers.
  • Implement macros getString and displayString. The macros may use Irvine’s ReadString to get input from the user, and WriteString to display output.
      o getString should display a prompt, then get the user’s keyboard input into a memory location
      o displayString should the string stored in a specified memory location.
      o readVal should invoke the getString macro to get the user’s string of digits. It should then convert the digit string to numeric, while validating the user’s input.
      o writeVal should convert a numeric value to a string of digits, and invoke the displayString macro to produce the output.
  • Write a small test program that gets 10 valid integers from the user and stores the numeric values in an array. The program then displays the integers, their sum, and their average.

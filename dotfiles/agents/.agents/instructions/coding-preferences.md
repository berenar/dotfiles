## Coding Preferences

### General

Do not add code comments, the code should be self-explanatory.
Avoid nested ternary operators, except for very simple one-level ternary operators, use IF ELSE instead.
Avoid using complex if else flows, use `if` only on one level and early `return` to avoid nesting.
Use descriptive variable and function names
Use built-in modules and avoid external dependencies where possible
Ask the user if you require any additional dependencies before adding them

Follow the SOLID principles when coding:

- Single Responsibility Principle: Each class or module should have one and only one reason to change.
- Open/Closed Principle: Software should be open for extension but closed for modification.
- Liskov Substitution Principle: Subclasses must be usable in place of their base classes without altering correctness.
- Interface Segregation Principle: Prefer many small, specific interfaces over a single, large, general one.
- Dependency Inversion Principle: High-level modules should not depend on low-level modules; both should depend on abstractions.

### TypeScript and JavaScript

Prefer async/await to promise/then.
Prefer `import` than using "require(something)".
Prefer named imports, avoid default imports if possible.
Don't use `any`, try to use the correct type, use `unknown` as last resource.
Don't use `let`, prefer using `const`.

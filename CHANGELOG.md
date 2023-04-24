## Future releases
- Easy integration in Rails
- Allow to pick your own infinity format

# 1.1.1
- Fix version name typo

# 1.1.0
- Add official support for ruby 3.2.2

## 1.0.1
- Fix options validator bug
- Modify gem description

## 1.0.0

- Adds support for Time and Unix timestamps
- Allows to pick preferred format for the output: Time or Unix timestamps.
- Allow to pick your timezone when choosing time format
- Ruby ranges are not accepted anymore as input
- Float::INFINITY replaces Nil class to represent time infinity
- Major architectural internal changes to improve maintainability

## 0.2.0
- Active Support dependency removal
- Minor changes: removal of Gemfile.lock / wrap classes in a module to avoid clash with other code sources

## 0.1.0
- Availabilities calculation with dates
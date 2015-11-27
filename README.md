# lita-pomodoro

This is a Lita handler that the popular chat bot can use to keep track of your team members' pomodoro sessions.

## Installation

Add lita-pomodoro to your Lita instance's Gemfile:

``` ruby
gem "lita-pomodoro"
```

## Configuration

n/a

## Usage

with this handler, Lita will respond to these commands (they need to be directed at them via @<name> or pm):

    start - Start a pomodoro session of 25 minutes in length.
    30 - Start a pomodoro session of 30 minutes in length.
    until TIME - Start a pomodoro session lasting until TIME (ex: until 5:00pm).
    stop - Stop a pomodoro session.
    list - List everyone who's pomodoroing right now.

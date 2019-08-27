workflow "New workflow" {
  on = "push"
  resolves = ["Hugo action"]
}

action "Hugo action" {
  uses = "./"
  runs = "hugo"
}

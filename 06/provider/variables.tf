variable "allowed_repo_branches" {
  type = list(object({
    username = string
    repo = string
    branch = string
  }))
  description = "assume roleできるGitリポジトリ配列"
  default = [ {
    username = "kuritaeiji"
    repo = "terraform-book"
    branch = "main"
  } ]
}
include {
  path = find_in_parent_folders()
}

inputs = yamldecode(file(find_in_parent_folders("common.yaml")))

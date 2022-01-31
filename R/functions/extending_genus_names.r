extend_genus_names <- function(species_vector_by_group) { # Alban Sagouis, 2019
  if (!all(substr(species_vector_by_group, 2, 2) == ".")) { # if all genus names of a given study are shortened, do nothing.
    for (i in unique(species_vector_by_group)) {
      if (!grepl(x = i, pattern = "^([A-Z])\\..")) {
        previous <- i
        next
      }

      first_letter <- substr(i, 1, 1)
      if (substr(previous, 1, 1) != first_letter) {
        warning(paste("previous species and i don't match", i))
        next
      }

      # extract first word of previous
      first_word <- gsub(x = previous, pattern = "\\ .*", replacement = "")

      # replace the first letter of i by first_word
      new_name <- gsub(x = i, pattern = "^([:A-Z:])\\.", replacement = first_word)
      species_vector_by_group[species_vector_by_group == i] <- new_name

      previous <- new_name # In the loop, previous is the previous species name in the list
    }
  }
  return(species_vector_by_group)
}

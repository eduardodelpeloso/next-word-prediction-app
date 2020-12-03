predict_next <- function(str1) {
  # Return if input is empty
  if (str1 == "") return()

  # Clean input the same way trainig corpora were cleaned
  # when generating the n-grams
  tokens <- gsub("\'", "", toLower(str1))
  tokens <- gsub("[\x01-\x1F\x80-\xFF]", "", tokens)
  tokens <- gsub("\"", "", tokens)
  tokens <- tokenize(tokens, what = "word", removeNumbers = TRUE,
                     removePunct = TRUE, removeSeparators = TRUE,
                     simplify = TRUE)
  
  # Results from searches inside n-gram will be registered
  # in these data frames
  scores_4 <- NULL
  scores_3 <- NULL
  scores_2 <- NULL
  
  # Number of tokens in the input string
  strLength <- length(tokens)
  
  # Search 4-grams (always)
  if (strLength >= 3) {
    sstr <- paste(tokens[strLength - 2], tokens[strLength - 1],
                  tokens[strLength])
    
    sind <- grep(paste("^", sstr, " ", sep = ""), tetragrams_cut[, 1])
    
    if (length(sind) > 0) {
      scores_4 <- data.frame(text = word(tetragrams_cut[sind, 1], -1),
                             count = tetragrams_cut[sind, 2])
      
      total_counts_4 <- sum(scores_4[, 2])
      
      scores_4[, 2] <- scores_4[, 2] / total_counts_4
    }
  }
  
  # Search 3-grams (if the search in 4-grams lead to less
  # then 5 results)
  if ((is.null(scores_4) || dim(scores_4)[1] < 5) && strLength >= 2) {
    sstr <- paste(tokens[strLength - 1], tokens[strLength])
    
    sind <- grep(paste("^", sstr, " ", sep = ""), trigrams_cut[, 1])
    
    if (length(sind) > 0) {
      scores_3 <- data.frame(text = word(trigrams_cut[sind, 1], -1),
                             count = trigrams_cut[sind, 2])
      
      total_counts_3 <- sum(scores_3[, 2])
      
      for (i in 1:nrow(scores_3)) {
        indfind <- grep(paste("^", scores_3[i, 1], "$", sep = ""), scores_4[, 1])
        if (length(indfind) > 0) {
          scores_4[indfind, 2] <- scores_4[indfind, 2] + scores_3[i, 2] * 0.4 /
            total_counts_3
        } else {
          linha <- data.frame(text = scores_3[i, 1],
                              count = scores_3[i, 2] * 0.4 / total_counts_3)
          scores_4 <- rbind(scores_4, linha)
        }
      }
    }
  }
  
  # Search 2-grams (if the searches in 4-grams and 3-grams lead to less
  # then 5 results)
  if ((is.null(scores_4) || dim(scores_4)[1] < 5) && strLength >= 1) {
    sstr <- tokens[strLength]
    
    sind <- grep(paste("^", sstr, " ", sep = ""), bigrams_cut[, 1])
    
    if (length(sind) > 0) {
      scores_2 <- data.frame(text = word(bigrams_cut[sind, 1], -1),
                             count = bigrams_cut[sind, 2])
      
      total_counts_2 <- sum(scores_2[, 2])
      
      for (i in 1:nrow(scores_2)) {
        indfind <- grep(paste("^", scores_2[i, 1], "$", sep = ""), scores_4[, 1])
        if (length(indfind) > 0) {
          scores_4[indfind, 2] <- scores_4[indfind, 2] + scores_2[i, 2] * 0.4 *
            0.4 / total_counts_2
        } else {
          linha <- data.frame(text = scores_2[i, 1],
                              count = scores_2[i, 2] * 0.4 * 0.4 / total_counts_2)
          scores_4 <- rbind(scores_4, linha)
        }
      }
    }
  }

  if (!is.null(scores_4)) {
    # Sort results
    scores_4 <- scores_4[order(-scores_4$count), ]
  
    # Return the 5 best results
    names(scores_4)[1] <- "Next word"
    names(scores_4)[2] <- "Grade"
    
    result <- scores_4[1:5, ]
    result[, 2] <- result[, 2] * 100.0 / result[1, 2]
  } else {
    result = as.data.frame(NULL)
  }
  
  return(result)
}

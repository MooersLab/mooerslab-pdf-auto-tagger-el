;;; mooerslab-pdf-auto-tagger.el --- Automatically tag PDF files based on filenames

;;; Commentary:
;; This package automatically generates and applies tags to PDF files on macOS
;; based on their filenames. It extracts the title from filenames following
;; the pattern AuthorYEARTitle.pdf and generates relevant tags using NLP.

;; Copyright (C) 2025 Blaine Mooers and the University of Oklahoma Board of Regents

;; Author: blaine-mooers@ou.edu
;; Maintainer: blaine-mooers@ou.edu
;; URL: https://github.com/MooersLab/mooerslab-pdf-auto-tagger-el
;; Version: 0.1
;; Keywords: pdf, tags, automation, MacOS
;; License: MIT
;; Updated 2025 November 16


;;; Code:

;;; Code:

(require 'json)

(defcustom mooerslab-pdf-tagger-python-command "python3"
  "Command to invoke Python 3."
  :type 'string
  :group 'mooerslab-pdf-tagger)

(defcustom mooerslab-pdf-tagger-max-tags 3
  "Maximum number of tags to generate per PDF."
  :type 'integer
  :group 'mooerslab-pdf-tagger)

(defcustom mooerslab-pdf-tagger-use-nlp t
  "Whether to use NLP for tag extraction (requires spaCy).
If nil, uses simple keyword extraction."
  :type 'boolean
  :group 'mooerslab-pdf-tagger)

(defvar mooerslab-pdf-tagger-python-script
  "#!/usr/bin/env python3
import sys
import json
import re
from collections import Counter

def simple_extract_keywords(title, max_keywords=3):
    \"\"\"Extract keywords using simple rule-based approach.\"\"\"
    # Common stop words to filter out
    stop_words = {
        'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for',
        'of', 'with', 'by', 'from', 'up', 'about', 'into', 'through', 'during',
        'including', 'until', 'against', 'among', 'throughout', 'despite',
        'towards', 'upon', 'concerning', 'introduction', 'guide', 'handbook',
        'manual', 'book', 'edition', 'volume', 'vol', 'tutorial', 'using',
        'practical', 'applied', 'basics', 'fundamentals', 'advanced', 'complete'
    }
    
    # Split on capital letters and clean
    words = re.findall(r'[A-Z][a-z]+|[0-9]+', title)
    words = [w.lower() for w in words if w.lower() not in stop_words and len(w) > 2]
    
    # Count word frequency
    word_freq = Counter(words)
    
    # Get most common words
    keywords = [word for word, count in word_freq.most_common(max_keywords)]
    
    # If we do not have enough keywords, add some subject-specific ones
    title_lower = title.lower()
    domain_keywords = {
        'programming': ['programming', 'code', 'software'],
        'mathematics': ['math', 'algebra', 'calculus', 'geometry'],
        'physics': ['physics', 'mechanics', 'quantum'],
        'chemistry': ['chemistry', 'molecular', 'chemical'],
        'biology': ['biology', 'molecular', 'genetics'],
        'machine learning': ['machine-learning', 'ai', 'neural-networks'],
        'data science': ['data-science', 'statistics', 'analytics'],
        'emacs': ['emacs', 'elisp', 'text-editor'],
        'lisp': ['lisp', 'functional-programming'],
        'python': ['python', 'programming'],
        'fortran': ['fortran', 'scientific-computing'],
        'haskell': ['haskell', 'functional-programming'],
        'clojure': ['clojure', 'jvm', 'functional-programming'],
        'mathematica': ['mathematica', 'computational-math'],
        'crystallography': ['crystallography', 'protein-structure', 'xray'],
        'graphics': ['graphics', 'visualization', 'design']
    }
    
    for domain, tags in domain_keywords.items():
        if domain.replace(' ', '').lower() in title_lower.replace(' ', ''):
            keywords.extend([t for t in tags if t not in keywords])
            break
    
    return keywords[:max_keywords]

def nlp_extract_keywords(title, max_keywords=3):
    \"\"\"Extract keywords using spaCy NLP.\"\"\"
    try:
        import spacy
        from collections import Counter
        
        # Load English model
        try:
            nlp = spacy.load('en_core_web_sm')
        except OSError:
            # Model not installed, fall back to simple extraction
            return simple_extract_keywords(title, max_keywords)
        
        # Add spaces before capitals for better parsing
        spaced_title = re.sub(r'([a-z0-9])([A-Z])', r'\\1 \\2', title)
        
        # Process with spaCy
        doc = nlp(spaced_title)
        
        # Extract nouns and proper nouns
        keywords = []
        for token in doc:
            if token.pos_ in ['NOUN', 'PROPN'] and not token.is_stop:
                keywords.append(token.lemma_.lower())
        
        # Extract noun chunks
        for chunk in doc.noun_chunks:
            if len(chunk.text.split()) <= 2:  # Only short phrases
                keywords.append(chunk.text.lower().replace(' ', '-'))
        
        # Count and return most common
        keyword_freq = Counter(keywords)
        return [kw for kw, _ in keyword_freq.most_common(max_keywords)]
    
    except ImportError:
        # spaCy not installed, fall back to simple extraction
        return simple_extract_keywords(title, max_keywords)

def main():
    if len(sys.argv) != 3:
        print(json.dumps({'error': 'Usage: script.py <title> <use_nlp>'}))
        sys.exit(1)
    
    title = sys.argv[1]
    use_nlp = sys.argv[2].lower() == 'true'
    
    if use_nlp:
        keywords = nlp_extract_keywords(title)
    else:
        keywords = simple_extract_keywords(title)
    
    print(json.dumps({'keywords': keywords}))

if __name__ == '__main__':
    main()
"
  "Python script for extracting keywords from PDF titles.")

(defun mooerslab-pdf-tagger--parse-filename (filename)
  "Parse FILENAME to extract author, year, and title.
Returns a plist with :author, :year, and :title keys.
Returns nil if filename does not match expected pattern."
  (when (string-match "\\`\\([A-Za-z]+\\)\\([0-9X]+\\)\\(.*\\)\\.\\(pdf\\|epub\\|chm\\)\\'" filename)
    (list :author (match-string 1 filename)
          :year (match-string 2 filename)
          :title (match-string 3 filename)
          :extension (match-string 4 filename))))

(defun mooerslab-pdf-tagger--title-to-readable (title)
  "Convert CamelCase TITLE to readable format with spaces."
  (let ((result "")
        (len (length title)))
    (dotimes (i len)
      (let ((char (aref title i))
            (prev-char (if (> i 0) (aref title (1- i)) nil))
            (next-char (if (< i (1- len)) (aref title (1+ i)) nil)))
        ;; Add space before uppercase if previous is lowercase/digit and next is lowercase
        (when (and prev-char
                  next-char
                  (or (and (>= prev-char ?a) (<= prev-char ?z))
                      (and (>= prev-char ?0) (<= prev-char ?9)))
                  (and (>= char ?A) (<= char ?Z))
                  (and (>= next-char ?a) (<= next-char ?z)))
          (setq result (concat result " ")))
        (setq result (concat result (char-to-string char)))))
    result))

(defun mooerslab-pdf-tagger--extract-tags (title)
  "Extract tags from TITLE using Python NLP.
Returns a list of tag strings."
  (let* ((temp-script (make-temp-file "pdf-tagger" nil ".py"))
         (readable-title (mooerslab-pdf-tagger--title-to-readable title))
         tags)
    (unwind-protect
        (progn
          ;; Write Python script to temp file
          (with-temp-file temp-script
            (insert mooerslab-pdf-tagger-python-script))
          (make-file-executable temp-script)
          
          ;; Execute Python script
          (let* ((use-nlp-str (if mooerslab-pdf-tagger-use-nlp "true" "false"))
                 (output (shell-command-to-string
                         (format "%s %s '%s' '%s'"
                                mooerslab-pdf-tagger-python-command
                                (shell-quote-argument temp-script)
                                readable-title
                                use-nlp-str)))
                 (result (condition-case err
                            (json-read-from-string output)
                          (error
                           (message "Error parsing JSON: %s" err)
                           nil))))
            (when result
              (setq tags (cdr (assoc 'keywords result))))))
      ;; Clean up temp file
      (delete-file temp-script))
    tags))

(defun mooerslab-pdf-tagger--apply-tags-macos (filepath tags)
  "Apply TAGS to FILEPATH using macOS tag command, preserving existing tags.
Returns t on success, nil on failure."
  (when (and filepath tags (file-exists-p filepath))
    (let* ((tag-string (mapconcat #'identity tags ","))
           ;; Use -a flag to add/append tags, preserving existing ones
           (command (format "tag -a '%s' '%s'"
                           tag-string
                           (expand-file-name filepath)))
           (result (shell-command command)))
      (= result 0))))

(defun mooerslab-pdf-tagger--get-existing-tags (filepath)
  "Get existing tags from FILEPATH on macOS.
Returns a list of tag strings."
  (when (file-exists-p filepath)
    (let* ((command (format "tag -l '%s'" (expand-file-name filepath)))
           (output (string-trim (shell-command-to-string command))))
      (when (and output (not (string-empty-p output)))
        (split-string output "\n" t)))))

;;;###autoload
(defun mooerslab-tag-pdfs-in-region (path-to-files)
  "Tag PDF files listed in region with automatically generated tags.
PATH-TO-FILES is the directory path where the PDF files are located.
Each line in the region should contain a PDF filename following the pattern:
AuthorYEARTitle.pdf

The function will:
1. Parse each filename to extract the title
2. Generate 3 relevant tags using NLP
3. Apply these tags to the PDF files on macOS

Requires macOS with 'tag' command available."
  (interactive "DPath to PDF files: ")
  (unless (use-region-p)
    (user-error "No region selected"))
  
  ;; Check if we are on macOS
  (unless (eq system-type 'darwin)
    (user-error "This function only works on macOS"))
  
  ;; Check if tag command is available
  (unless (executable-find "tag")
    (user-error "macOS 'tag' command not found. Please install it."))
  
  (let* ((start (region-beginning))
         (end (region-end))
         (lines (split-string (buffer-substring-no-properties start end) "\n" t))
         (results '())
         (success-count 0)
         (failure-count 0))
    
    (dolist (line lines)
      (let* ((filename (string-trim line))
             (parsed (mooerslab-pdf-tagger--parse-filename filename)))
        (if parsed
            (let* ((title (plist-get parsed :title))
                   (filepath (expand-file-name filename path-to-files))
                   (tags (mooerslab-pdf-tagger--extract-tags title))
                   (existing-tags (mooerslab-pdf-tagger--get-existing-tags filepath)))
              
                   (if (file-exists-p filepath)
                       (progn
                         (message "Processing: %s" filename)
                         (when existing-tags
                           (message "  Existing tags: %s" (mapconcat #'identity existing-tags ", ")))
                         (message "  New tags: %s" (mapconcat #'identity tags ", "))
                    
                         (if (mooerslab-pdf-tagger--apply-tags-macos filepath tags)
                             (progn
                               (setq success-count (1+ success-count))
                               (push (list :file filename
                                         :existing-tags existing-tags
                                         :new-tags tags
                                         :status 'success)
                                     results))
                      (setq failure-count (1+ failure-count))
                      (push (list :file filename
                                :status 'failed
                                :reason "Could not apply tags")
                            results)))
                (setq failure-count (1+ failure-count))
                (push (list :file filename
                          :status 'failed
                          :reason "File not found")
                      results)))
          (push (list :file filename
                    :status 'skipped
                    :reason "Invalid filename format")
                results))))
    
    ;; Display summary
    (let ((summary-buffer (get-buffer-create "*PDF Tagging Results*")))
      (with-current-buffer summary-buffer
        (erase-buffer)
        (insert (format "PDF Tagging Summary\n"))
        (insert (format "===================\n\n"))
        (insert (format "Successfully tagged: %d files\n" success-count))
        (insert (format "Failed: %d files\n\n" failure-count))
        (insert "Details:\n")
        (insert "--------\n\n")
        
        (dolist (result (reverse results))
          (let ((file (plist-get result :file))
                (status (plist-get result :status))
                (tags (plist-get result :tags))
                (reason (plist-get result :reason)))
            (insert (format "File: %s\n" file))
            (insert (format "Status: %s\n" status))
            
            (when (plist-get result :existing-tags)
              (insert (format "Existing tags: %s\n" 
                             (mapconcat #'identity (plist-get result :existing-tags) ", "))))
            (when tags
              (insert (format "Tags: %s\n" (mapconcat #'identity tags ", "))))
            (when reason
              (insert (format "Reason: %s\n" reason)))
            (insert "\n"))))
      
      (display-buffer summary-buffer)
      (message "Tagging complete. %d succeeded, %d failed." success-count failure-count))))

;;;###autoload
(defun mooerslab-show-pdf-tags (filepath)
  "Display tags for FILEPATH."
  (interactive "fPDF file: ")
  (let ((tags (mooerslab-pdf-tagger--get-existing-tags filepath)))
    (if tags
        (message "Tags for %s: %s" 
                (file-name-nondirectory filepath)
                (mapconcat #'identity tags ", "))
      (message "No tags found for %s" (file-name-nondirectory filepath)))))

;;;###autoload
(defun mooerslab-remove-pdf-tags (filepath tags)
  "Remove TAGS from FILEPATH."
  (interactive
   (let* ((file (read-file-name "PDF file: "))
          (existing-tags (mooerslab-pdf-tagger--get-existing-tags file))
          (tags-to-remove (completing-read-multiple
                          "Tags to remove: "
                          existing-tags)))
     (list file tags-to-remove)))
  (when (and filepath tags (file-exists-p filepath))
    (let* ((tag-string (mapconcat #'identity tags ","))
           (command (format "tag -r '%s' '%s'"
                           tag-string
                           (expand-file-name filepath)))
           (result (shell-command command)))
      (if (= result 0)
          (message "Successfully removed tags from %s" (file-name-nondirectory filepath))
        (message "Failed to remove tags from %s" (file-name-nondirectory filepath))))))

(provide 'mooerslab-pdf-auto-tagger)
;;; mooerslab-pdf-auto-tagger.el ends here
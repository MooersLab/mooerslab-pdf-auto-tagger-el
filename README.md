![Version](https://img.shields.io/static/v1?label=elfeedorg&message=0.1&color=brightcolor)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)


# Blaine's elfeed.org file of RSS feeds of interest

Elfeed is a package for the highly customizable text editor Emacs.
This package provides an interface to the most recent current contents of selected journals.
Elfeed provides direct links to each article for further exploration.
Elfeed spares you of the trouble of visiting the current contents of each journal to find papers of interest.
This form of literature searching compliments keyword or topic-driven searches.
You might not have considered certain terms to be relevant when they would be required to be able to retrieve literature that is relevant to your interests.

This repository contains my source file, elfeed.org, that has all the URLs to the RSS feeds of the journals that I follow.
Obviously, this file is written in the orb mode type setting language.
Org-mode is very convenient for the creation and management of hierarchical lists.
Some trees within the list can be shuffled up or down.
Org-mode also supports the folding of topics.
Org-mode was initiated before markdown and is far more powerful.
For example, org-mode supports parallel polyglot literate programming, which is not even possible in Jupyter notebooks.

The main kind of feed that I follow are the current contents of journals.
Some other kinds of websites like blogs will also have RSS feeds.

This collection of RSS feeds is driven by my research needs and interests. 
My interests include the following:

- Biochemistry
- Molecular Biology
- Parasitology
- Cancer Biology
- Protein Structure
- RNA structure
- RNA editing
- Biomolecular Crystallography
- Biological Quantum Crystallography
- Biological Small Angle Scatering
- Structure based Drug Design
- Moleciular Graphics
- Molecular Simulations
- Tools to assist with writing computer code
- Literate programming
- Computational Notebooks
- Reproducible research
- Classic and Modern Design of Experiments
- Bayesian Data Analysis
- Emacs
- Clojure

If you have overlapping interests, you may want to borrow the relevant entries because the gathering of the URLs for these feeds was time consuming.
The feeds are organized by publisher because each publisher has their own style of formatting the URL.
This approach to organizing the feeds supports more rapid deduction of the appropriate URL address.

To interface the elfeed.org file with elfeed, you need to install the package elfeed-org.
This is the configuration that I use in my init.el file:

```elisp
;; List the feeds in an org file here:
(use-package elfeed-org)
(setq rmh-elfeed-org-files (list "~/e30fewpackages/elfeed.org"))
(elfeed-org)
```



## Update history

|Version      | Changes                                                                                                                                                                         | Date                 |
|:-----------|:------------------------------------------------------------------------------------------------------------------------------------------------------------|:--------------------|
| Version 0.1 |   Added badges, funding, and update table.  Initial commit.                                                                                        | 11/13/2025  |
| Version 0.2 |  Changed the heirarchy in elfeedorg                                                                                                               ---------- | 11/14/2025  |

## Sources of funding

- NIH: R01 CA242845
- NIH: R01 AI088011
- NIH: P30 CA225520 (PI: R. Mannel)
- NIH: P20 GM103640 and P30 GM145423 (PI: A. West)

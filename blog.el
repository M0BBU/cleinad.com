;; -*- mode: emacs-lisp; lexical-binding: t -*-
(require 'ox-publish)
(require 'ox-rss)

(defconst cleinad/css-head
  "<link rel=\"stylesheet\" href=\"/static/style.css?v=1.2\" type=\"text/css\"/>
   <link rel=\"icon\" href=\"/static/images/herodotus.webp\" type=\"image/webp\">"
  "Custom CSS for blog.")

(defconst cleinad/page-html-preamble
  "<header>
    <img src=\"/static/images/herodotus.webp\" alt=\"herodotus\" class=\"logo\">
    <b>cleinad. a blog.</b>
      <nav>
        <a href=\"/\">home</a>
        <a href=\"/about.html\">about</a>
        <a href=\"/rss.xml\">rss</a>
      </nav>
  </header>"
  "The default html preamble appended to all pages.")

(defconst cleinad/post-html-preamble
  "<h1 class=\"title\">%t</h1>
    <div class=\"blogdescription\">
      <p>%s</p>
      <p>Last Updated: %C</p>
    </div>"
  "The post specific html preamble.")

(setq org-export-global-macros
      '(("timestamp" . "@@html:<span class=\"posttimestamp\">$1</span>@@")))

(defun cleinad/org-sitemap-date-entry-format (entry style project)
  "Format ENTRY in org-publish PROJECT Sitemap format ENTRY ENTRY STYLE format that includes date."
  (let ((filename (org-publish-find-title entry project)))
    (if (= (length filename) 0)
        (format "*%s*" entry)
      (format "[[file:%s][%s]] {{{timestamp(%s)}}}"
              entry
              filename
              (format-time-string "%b %d %Y"
                                  (org-publish-find-date entry project))))))

(defun cleinad/org-publish-sitemap (title list)
  "This takes the org-publish-sitemap-default function and also adds a ATTR_HTML
element so that we can apply some specific CSS rules just for the sitemap.

Default site map, as a string.TITLE is the title of the site map.  LIST is an
internal representation for the files to include, as returned by
`org-list-to-lisp'.  PROJECT is the current project."
  (concat "#+TITLE: " title "\n\n" "#+ATTR_HTML: :id sitemap\n"
	      (org-list-to-org list)))

(defun cleinad/org-rss-publish-to-rss (plist filename pub-dir)
  "Publish RSS with PLIST, only when FILENAME is 'rss.org'.
PUB-DIR is when the output will be placed."
  (if (equal "rss.org" (file-name-nondirectory filename))
      (org-rss-publish-to-rss plist filename pub-dir)))

(defun cleinad/format-rss-feed (title list)
  "Generate RSS feed, as a string.
TITLE is the title of the RSS feed.  LIST is an internal
representation for the files to include, as returned by
`org-list-to-lisp'."
  (concat "#+TITLE: " title "\n\n"
          (org-list-to-subtree list 1)))

(defun cleinad/format-rss-feed-entry (entry style project)
  (let ((file (org-publish--expand-file-name entry project)))
    (cond
     ((not (directory-name-p entry))
      (format "* %s\n:PROPERTIES:\n:RSS_PERMALINK: %s.html\n:PUBDATE: %s\n:END:\n"
              (org-publish-find-title entry project)
              (file-name-sans-extension entry)
              (format-time-string "%Y-%m-%d" (org-publish-find-date entry project))))
     ((eq style 'tree)
      (file-name-nondirectory (directory-file-name entry)))
     (t entry))))

(setq org-publish-project-alist
      `(("pages"
         :base-directory "~/code/cleinad.com"
         :base-extension "org"
         :recursive nil
         :section-numbers nil
         :exclude "README.org"
         :with-toc nil
         :with-tags t
         :with-title nil
         :html-postamble nil
         :html-preamble ,cleinad/page-html-preamble
         :html-head-include-default-style nil
         :html-footnotes-section ""
         :html-head ,cleinad/css-head
         :publishing-directory "~/code/cleinad.com/html"
         :publishing-function org-html-publish-to-html)

        ("posts"
         :base-directory "~/code/cleinad.com/posts"
         :htmlized-source t
         :base-extension "org"
         :recursive nil
         :exclude "rss.org"
         :section-numbers nil
         :with-toc t
         :with-tags t
         :with-title nil
         :auto-sitemap t
         :sitemap-format-entry cleinad/org-sitemap-date-entry-format
         :sitemap-sort-files anti-chronologically
         :sitemap-function cleinad/org-publish-sitemap
         :html-postamble nil
         :html-preamble ,(concat cleinad/page-html-preamble cleinad/post-html-preamble)
         :html-head-include-default-style nil
         :html-footnotes-section ""
         :html-head ,cleinad/css-head
         :publishing-directory "~/code/cleinad.com/html/posts"
         :publishing-function org-html-publish-to-html)

        ("static"
         :base-directory "~/code/cleinad.com/static"
         :recursive t
         :base-extension "css\\|txt\\|jpg\\|gif\\|png\\|ttf\\|otf\\|webp"
         :publishing-directory "~/code/cleinad.com/html/static"
         :publishing-function org-publish-attachment)

        ("rss"
	       :base-directory "~/code/cleinad.com/posts"
	       :base-extension "org"
           :exclude "sitemap.org"
           :auto-sitemap t
           :author "Dan C"
           :email "m0bbu@pm.me"
           :sitemap-format-entry cleinad/format-rss-feed-entry
           :sitemap-sort-files anti-chronologically
           :sitemap-function cleinad/format-rss-feed
           :sitemap-filename "rss.org"
	       :publishing-directory "~/code/cleinad.com/html"
	       :publishing-function cleinad/org-rss-publish-to-rss
	       :html-link-home "https://cleinad.com/"
	       :html-link-use-abs-url t)

        ("cleinad.com" :components ("pages" "posts" "static" "rss"))))

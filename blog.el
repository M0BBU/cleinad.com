;; -*- mode: emacs-lisp; lexical-binding: t -*-

(require 'ox-publish)

(defconst cleinad/css-head
  "<link rel=\"stylesheet\" href=\"/static/style.css?v=1.1\" type=\"text/css\"/>
   <script src=\"/static/scripts/highlight.min.js\"></script>
   <script>hljs.highlightAll();</script>
   <link rel=\"icon\" href=\"/static/images/herodotus.png\" type=\"image/png\">"
  "Custom CSS for blog.")

(defconst cleinad/page-html-preamble
  "<header>
    <img src=\"/static/images/herodotus.png\" alt=\"herodotus\" class=\"logo\">
    <b>cleinad. a blog.</b>
      <nav>
        <a href=\"/\">home</a>
        <a href=\"/about.html\">about</a>
      </nav>
  </header>"
  "The default html preamble appended to all pages.")

(defconst cleinad/post-html-preamble
  "<h1 class=\"title\">%t</h1>
    <div class=\"blogdescription\">
      <p>%s</p>
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
              (format-time-string "%Y-%m-%d"
                                  (org-publish-find-date entry project))))))

(setq org-publish-project-alist
      `(("pages"
         :base-directory "~/code/cleinad.com"
         :base-extension "org"
         :recursive nil
         :section-numbers nil
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
         :section-numbers nil
         :with-toc t
         :with-tags t
         :with-title nil
         :auto-sitemap t
         :sitemap-format-entry cleinad/org-sitemap-date-entry-format
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
         :base-extension "css\\|txt\\|jpg\\|gif\\|png\\|ttf\\|otf"
         :publishing-directory "~/code/cleinad.com/html/static"
         :publishing-function org-publish-attachment)

        ("cleinad.com" :components ("pages" "posts" "static"))))

(org-publish "cleinad.com" t)

;; -*- mode: emacs-lisp; lexical-binding: t -*-

(require 'ox-publish)

(defconst cleinad/css-head
  "<link rel=\"stylesheet\" href=\"/static/style.css\" type=\"text/css\"/>"
  "Custom CSS for blog.")

(defconst cleinad/page-html-preamble
  "<header>
    <b>cleinad. a blog.</b>
      <nav>
        <a href=\"/html\">home</a>
      </nav>
  </header>"
  "The default html preamble appended to all pages.")

(defconst cleinad/post-html-preamble
  "<h1 class=\"title\">%t</h1>
    <div class=\"blogdescription\">
      <p class=\"date\">%d</p>
      <p>%s</p>
    </div>"
  "The post specific html preamble.")

(setq org-export-global-macros
      '(("timestamp" . "@@html:<span class=\"posttimestamp\">$1</span>@@")))

(setq org-footnote-define-inline t)

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

(defun cleinad/org-html-footnote-as-sidenote (footnote-reference _contents info)
  "Transcode a FOOTNOTE-REFERENCE element from Org to HTML, but displays the actual
CONTENTS as a sidenote. INFO is a plist holding contextual information."
  (concat
   ;; Insert separator between two footnotes in a row.
   (let ((prev (org-export-get-previous-element footnote-reference info)))
     (when (org-element-type-p prev 'footnote-reference)
       (plist-get info :html-footnote-separator)))
   (let* ((n (org-export-get-footnote-number footnote-reference info))
          (label (org-element-property :label footnote-reference))
          ;; Do not assign number labels as they appear in Org mode -
          ;; the footnotes are re-numbered by
          ;; `org-export-get-footnote-number'.  If the label is not a
          ;; number, keep it.
          (label (if (and (stringp label)
                          (equal label (number-to-string (string-to-number label))))
                          nil
                   label))
	  (id (format "fnr.%s%s"
		      (or label n)
		      (if (org-export-footnote-first-reference-p
			   footnote-reference info)
			  ""
                        (let ((label (org-element-property :label footnote-reference)))
                          (format
                           ".%d"
                           (org-export-get-ordinal
                            footnote-reference info '(footnote-reference)
                            `(lambda (ref _)
                               (if ,label
                                   (equal (org-element-property :label ref) ,label)
                                 (not (org-element-property :label ref)))))))))))
     (format
      "<label for=\"sn.%s\" class=\"margin-toggle sidenote-number\">
       </label>
       <input type=\"checkbox\" id=\"sn.%s\" class=\"margin-toggle\"/>
       <span class=\"sidenote\">
       %s
       </span>"
      (or label n)
      (or label n)
      _contents))))

(advice-add 'org-html-footnote-reference :override #'cleinad/org-html-footnote-as-sidenote)

(setq org-publish-project-alist
      `(("pages"
         :base-directory "~/src/me/cleinad.com"
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
         :publishing-directory "~/src/me/cleinad.com/html"
         :publishing-function org-html-publish-to-html)

        ("posts"
         :base-directory "~/src/me/cleinad.com/posts"
         :base-extension "org"
         :recursive nil
         :section-numbers nil
         :with-toc nil
         :with-tags t
         :with-date t
         :with-title nil
         :auto-sitemap t
         :sitemap-format-entry cleinad/org-sitemap-date-entry-format
         :html-postamble nil
         :html-preamble ,(concat cleinad/page-html-preamble cleinad/post-html-preamble)
         :html-head-include-default-style nil
         :html-footnotes-section ""
         :html-head ,cleinad/css-head
         :publishing-directory "~/src/me/cleinad.com/html/posts"
         :publishing-function org-html-publish-to-html)

        ("static"
         :base-directory "~/src/me/cleinad.com/static"
         :recursive t
         :base-extension "css\\|txt\\|jpg\\|gif\\|png\\|ttf\\|otf"
         :publishing-directory "~/src/me/cleinad.com/html/static"
         :publishing-function org-publish-attachment)

        ("cleinad.com" :components ("pages" "posts" "static"))))

(org-publish "cleinad.com" t)

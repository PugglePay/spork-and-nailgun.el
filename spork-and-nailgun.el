;;; spork-and-nailgun.el

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

(defun sang-trim-string (string)
  (replace-regexp-in-string
   "\\`[ \t\n]*" ""
   (replace-regexp-in-string "[ \t\n]*\\'" "" string)))

(defcustom sang-nailgun-port "2113" "Port to use for nailgun")
(defcustom sang-spork-port   "8989" "Port to use for spork")

(defun sang-pid-for (port)
  (let (pid (trim-string (shell-command-to-string (concat "lsof -t -i :" port))))
    (if (string= pid "") nil pid)))

(defun sang-kill-pid (pid)
  (when pid
      (shell-command (concat "kill -9 " pid))))

(defun sang-kill-nailgun ()
  (interactive)
  (sang-kill-pid (sang-pid-for sang-nailgun-port)))

(defun sang-kill-spork ()
  (interactive)
  (sang-kill-pid (sang-pid-for sang-spork-port)))

(defun sang-kill-all ()
  (interactive)
  (sang-kill-nailgun)
  (sang-kill-spork))

(defun sang-exec (command buffer)
 (cd (ffip-project-root))
 (when (require 'rvm nil t)
   (rvm-activate-corresponding-ruby))
 (async-shell-command command buffer))

(defun sang-start-spork ()
  (interactive)
  (sang-exec (concat "spork --p " sang-spork-port) "*spork*"))

(defun sang-start-nailgun ()
  (interactive)
  (sang-exec (concat "jruby --ng-server " sang-nailgun-port) "*nailgun*"))

(defun sang-start-all ()
  (interactive)
  (save-excursion
    (sang-kill-all)
    (sit-for 10)
    (when (get-buffer "*spork*")   (kill-buffer "*spork*"))
    (when (get-buffer "*nailgun*") (kill-buffer "*nailgun*"))
    (sang-start-nailgun)
    (sang-start-spork)))

(provide 'spork-and-nailgun)

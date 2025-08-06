I (Wowfunhappy) recompiled this XPC service for his modified copy of Chocolat, because the one that shipped with the app kept crashing with some sort of use-after-free. Then I also updated libgit2 to version 1.3.2 because I figured I might as well.

To compile libgit, make sure cmake can't find the MacPorts copies of openssl and iconv:

sudo mv /opt/local/include/iconv.h /opt/local/include/iconv.h.disabled
sudo mv /opt/local/include/openssl /opt/local/include/openssl.disabled

Then you can:

cmake .. -DBUILD_SHARED_LIBS=OFF -DTHREADSAFE=ON -DBUILD_CLAR=OFF


-----

# git.xpc

Git support for Chocolat.

## Design

* Status checking (+ support for SVN, hg)
* Gutter? (http://git.io/5MQH1A)
* Project bar status (the way Xcode 5 shows it is nice)
* Menu for various git commands, e.g. git fsck

Implementation:

* XPC service

* Use **libgit2** or https://github.com/libgit2/objective-git for git stuff. I'm leaning towards raw libgit2 for easiness.

* Three features: directory status (git, hg, svn), file diffs (git only), git operations (add, commit, pull, push, etc)

* 1. Question: how big is objective-git when compiled? Might just want to use the user's already-there command line tools rather than shipping a whole fucking git with Chocolat

* 2. Also if we use objective-git, doesn't that mean we have to keep updating it every time there's a new (lib)git version?

* 3. That said objective-git is way nicer than parsing output gotten from NSTask. Man that's always a clusterfuck.

* **Message**: `{ "type": "status", "path": "path/to/directory" }`

* - **Response**: `{ "files": [ { "path": "path/to/directory/file.txt", "status": "added" } ] }`

* - **Note**: only include statuses for files in the directory that are not blank!

* - **Note**: we do whole-directory status because that's what makes sense for the source list

* **Message**: `{ "type": "diff", "path": "path/to/file.txt" }`

* - **Response**: ???

* **Message**: `{ "type": "commit", "path": "path/to/file.txt" }`

* - **Response**: ???


## License

WTFPL.

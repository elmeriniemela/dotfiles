# Repository guidelines

- Minimize maintained code and configuration; remove redundancy before adding tooling.
- Keep `.install.sh` rerunnable, simple and easy to review.
- Avoid complex logic, prefer simple commands instead of loops, if's or other special control statements.
- Setup scripts must not clean up or migrate files from older repository versions, always assume a fresh install.

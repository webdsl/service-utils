# WebDSL Service Utils

Repository for exploring possible improvements to WebDSL Services.

## Usage

```
cd groove
# to make use of the compile server
webdsl start &
# run the app
webdsl run
# run the tests
webdsl check
# run the web tests
webdsl check-web
```

## TODOs

- [ ] Documentation
  - [ ] Repository: Installation, Structure, How to run/develop
  - [ ] API: Document the REST interface of all explorations
  - [ ] Current code: REST API design decisions
- [ ] Project
  - [x] Adjust groove project
    - [x] Remove frontend & themeing
    - [x] Make runnable
    - [ ] Does the application logic stay?
  - [x] Add GET,PUT endpoints
  - [ ] Update Dockerfile(s)
- [ ] Tests
  - [x] Fix current test:  ERROR JDBCExceptionReporter:234 - Referential integrity constraint violation
  - [ ] Unit tests
  - [x] Figure out how to test REST endpoints with web tests
  - [x] Add tests for the endpoints (auth, response body|header|status)
  - [ ] Is there something like coverage reports for WebDSL?
- [x] WebDSL buildfarm integration
- [ ] Don't abuse the README and use tagged GitHub issues for this...

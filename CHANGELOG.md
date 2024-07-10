# Changelog

## [Unreleased]

### Changed

- [TD-6602] Update td-cache

## [6.8.0] 2024-07-03

### Added

- [TD-6499] Messages for content origin icons and labels
- [TD-4647] Messages for structure pending notes

## [6.7.0] 2024-06-13

### Added

- [TD-5788] Added translations for grant_requests

## [6.6.0] 2024-05-21

### Added

- [TD-6455] Added translations for filters updated_at

## [6.5.0] 2024-04-30

### Added

- [TD-6424] Added translation for implementation type
- [TD-5520] Added new permission group messages

## [6.3.0] 2024-03-20

### Added

- [TD-6433] Messages for AI Provider and Sandbox
- [TD-4110] Messages for tab roles in structures view

## [6.2.0] 2024-02-26

### Added

- [TD-6243] Support for deleting Elasticsearch indexes
- [TD-6258] Support of locales in cache
- [TD-6223] Allow custom configuration of global search page

### Fixed

- [TD-6425] Ensure SSL if configured for release migration

## [6.1.0] 2024-02-08

### Added

- [TD-6339] Messages for search refactor
- [TD-6306] Empty catalog view message

### Changed

- [TD-6374] Refactor locales to include lang manager

## [6.0.0] 2024-01-17

### Added

- [TD-6205] Conpets upload messages
- [TD-6221] Messages for AI management
- [TD-6195] Messages for AI Suggestions in Business Concepts
- [TD-6336] Get test-truedat-eks config on deploy stage
- [TD-6243] Messages for deleting Elasticsearch indexes

### Fixed

- [TD-6167] Schedule Job to load locales in prod config

## [5.20.0] 2023-12-19

### Added

- [TD-5505] Grant removal request workflow
- [TD-6167] Multi language administrator
- [TD-6152] Messages for QX executions

## [5.19.0] 2023-11-28

### Added

- [TD-6140] Messages for AI suggestions on StructureNotes

## [5.18.0] 2023-11-13

### Added

- [TD-4304] Messages for linked structures filter
- [TD-3062] Messages for Templates table and Form
- [TD-5542] Structure Alias Name Selector messages

## [5.17.0] 2023-11-02

### Added

- [TD-6059] Messages for td-qx QualityControls

## [5.16.0] 2023-10-18

### Added

- [TD-5540] GrantRequest approval bulk with elasticsearch messages

## [5.15.0] 2023-10-02

### Added

- [TD-5947] Messages for Qx DataViews

## [5.13.0] 2023-09-05

### Added

- [TD-5798] Filter related concepts graph by tag messages
- [TD-5928] Deprecated concepts messages

## [5.12.0] 2023-08-16

### Added

- [TD-4557] Messages for Qx DataSets
- [TD-5936] Messages for HasNote column in structure view
- [TD-5891] I18n cache message support

## [5.11.0] 2023-07-24

### Added

- [TD-5872] Add link to concepts in downloaded files

## [5.10.1] 2023-07-11

### Added

- [TD-4986] Empty bucket translation

## [5.10.0] 2023-07-06

### Added

- [TD-5593] Add related concept in quality implementations list and implementation download

### Changed

- [TD-5912] `.gitlab-ci.yml` adaptations for develop and main branches

## [5.9.0] 2023-06-20

### Added

- [TD-5770] Add database TSL configuration
- [TD-5787] Add Elastic Search Boost option in templates

## [5.8.0] 2023-06-05

### Added

- [TD-3916] Hierarchy depth messages
- [TD-5747] Links concepts for link manager

## [5.7.0] 2023-05-23

### Added

- [TD-5491] Add link to the structure and the technical name in the downloded files of structures metadata
- [TD-5504] Structure domains for implementations

### Changed

- [TD-5756] Business concept title relation messages

## [5.6.0] 2023-05-09

### Added

- [TD-5661] Multiple structrures grant requests view
- [TD-4243] Data Structure Note Events

## [5.5.0] 2023-04-18

### Added

- [TD-5297] Added `DB_SSL` environment variable for Database SSL connection

## [5.3.0] 2023-03-13

### Added

- [TD-4438] Referenced in reference dataset field operator
- [TD-5509] Data structure link form messages
- [TD-3806] Messages for hierarchy widget

## [5.2.0] 2023-02-28

### Added

- [TD-5471] UploadModal update message
- [TD-5599] Messages for Tasks
- [TD-4554] Messages for concept links manager

### Remove

- [TD-3541] Unused messages

## [5.1.0] 2023-02-13

### Added

- [TD-5479] Messages for external_ref in grants
- [TD-5444] Message for structures showed when total exceed the limit

## [5.0.0] 2023-01-30

### Added

- [TD-5473] Messages for `structure_note_updated` subscription
- [TD-5300] Messages for ReferenceDataset domains
- [TD-5478] Added messages to convert basic implementation to default or raw
  implementation
- [TD-3805] Messages for Td-df Hierarchies

## [4.59.0] 2023-01-16

### Added

- [TD-1968] Endpoint to create multiple messages for the same `message_id`
- [TD-5199] Added messages for delete rule error if rule has active
  implementations

## [4.58.1] 2022-12-27

### Added

- [TD-3919] Add glossary and subscope translations
- [TD-5367] Update messages for grant details
- [TD-4300] Update messages for implementations and auth
- [TD-5368] Editable checkbox translation
- [TD-5369] Update messages for new subscription `remediation_created`

## [4.57.0] 2022-12-12

### Added

- [TD-5161] Update messages.json

## [4.56.0] 2022-11-28

### Added

- [TD-5336] New `i18n` service for managing i18n locales and messages
- [TD-4711] Startup task to delete deprecated messages

### Changed

- [TD-5338] `GET /api/locales/:id` now accepts `id` or `lang` as parameter

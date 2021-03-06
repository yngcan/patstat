# Patstat-IFRIS titles and abstracts

Below is a description of the tables and contents of the database after
translating titles/abstracts. If you want details on the process, go
[here](script.md). 

## Which patents were translated?

For Patstat-IFRIS we have translated titles and abstracts that were originally
written in the following languages:

| Language   | Language code |
|------------|---------------|
| German     | DE            |
| Portuguese | PT            |
| Spanish    | ES            |
| French     | FR            |
| Polish     | PL            |
| Dutch      | NL            |
| Italian    | IT            |
| Russian    | RU            |

## The database

There are two separate tables for titles and abstracts of the patents in the database: 

- **Titles**: tls202_appln_title
- **Abstracts**: tls203_appln_abstr

Both have a very similar structure, with columns for:

- patent identifier
- language
- title/abstract

We have added **an extra column** to these tables, which contains the title/abstract, in English.

## Table columns

### Titles (**tls202_appln_title**):

| column name    | content                                                               |
|----------------|-----------------------------------------------------------------------|
| appln_id       | The id of the patent. It is the same accross all of the database      |
| appln_title    | Title of the patent.                                                  |
| appln_title_lg | ISO 639-1 code of the language that the original title is written in. |
| appln_title_en | Content of appln_title, translated to English                         |

### Abstracts (**tls202_appln_abstr**):

| column name    | content                                                                  |
|----------------|--------------------------------------------------------------------------|
| appln_id       | The id of the patent. It is the same accross all of the database.        |
| appln_abstr    | Abstract of the patent.                                                  |
| appln_abstr_lg | ISO 639-1 code of the language that the original abstract is written in. |
| appln_abstr_en | Content of appln_abstr, translated to English.                           |

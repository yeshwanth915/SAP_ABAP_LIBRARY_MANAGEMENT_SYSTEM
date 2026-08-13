# SAP_ABAP-02-_RAP_LIBRARY_MANAGEMENT_SYSTEM

SAP RAP Library Management System is a book issue/return application built using SAP RAP, ABAP, and CDS views. It enables users to create, update, view, and manage a book catalog, with book availability tracking (Available / Issued) and structured data management through modern SAP technologies (Managed RAP Business Object with Draft, CDS View Entities, Behavior Definitions, and an OData V4 UI service).

## About the project

The idea came from observing how manual handling of library records can lead to errors, especially when tracking whether a book is available or already issued. This project is a simple system that manages book details and handles the issuing and returning of books efficiently.

A custom database table stores book information: **Book ID, Book Name, Author, and Status**. The main functionality is **issuing and returning books**:

- When a user tries to **issue** a book, the system first checks if the book is `AVAILABLE`. If it is, the status is updated to `ISSUED`; otherwise, the system raises an error message that the book is already issued.
- When a user **returns** a book, the status is updated back to `AVAILABLE` (only if it was currently `ISSUED`).

The project uses modern ABAP concepts — **CDS View Entities** and **RAP-based Behavior Definitions** — to structure the business logic, and defines custom RAP **actions** (`issueBook`, `returnBook`) that are exposed on a Fiori Elements List Report / Object Page UI via an OData V4 service.

---

## Data Model

| Field                 | Type            | Description                              |
|-----------------------|-----------------|-------------------------------------------|
| BookID                | NUMC(10)        | Key field, unique book identifier          |
| BookName              | CHAR(50)        | Title of the book                          |
| Author                | CHAR(50)        | Author of the book                         |
| Status                | CHAR(20)        | `AVAILABLE` or `ISSUED`                    |
| CreatedAt / CreatedBy | Admin fields    | Managed automatically by RAP               |
| LastChangedAt / By    | Admin fields    | Managed automatically by RAP               |
| LocalLastChangedAt    | Admin field     | ETag for draft/optimistic concurrency      |

## Repository Objects (`/src`)

| Object                          | Type                      | Purpose                                             |
|----------------------------------|---------------------------|------------------------------------------------------|
| `ZYESH_DB_LIB_SYS`               | Database Table            | Persists book master data                            |
| `ZYESH_DB_LIB_SS_D`              | Database Table            | Draft table for the business object                  |
| `ZR_YESH_DB_LIB_SYS`             | CDS View Entity (Interface)| Root interface view over the DB table                |
| `ZR_YESH_DB_LIB_SYS`             | Behavior Definition        | Managed RAP BO: create/update/delete, draft, actions  |
| `ZBP_R_YESH_DB_LIB_SYS`          | Behavior Implementation    | Determinations, validations, `issueBook`/`returnBook` |
| `ZC_YESH_DB_LIB_SYS`             | CDS View Entity (Projection)| Consumption/projection view for the UI               |
| `ZC_YESH_DB_LIB_SYS`             | Behavior Definition        | Projection behavior (exposes actions to UI)           |
| `ZBP_C_YESH_DB_LIB_SYS`          | Behavior Implementation    | Empty projection behavior class                       |
| `ZC_YESH_DB_LIB_SYS`             | Metadata Extension (DDLX)  | Fiori Elements UI annotations (list, facets, fields)  |
| `ZC_YESH_STATUS`                 | CDS View Entity            | Value help for the `Status` field                     |
| `ZUI_YESH_DB_LIB_SYS_O4`         | Service Definition         | Exposes `ZC_YESH_DB_LIB_SYS` as a service             |
| `ZUI_YESH_DB_LIB_SYS_O4`         | Service Binding (OData V4 UI)| Publishable OData V4 UI service                     |

## Business Logic

1. **`setInitialStatus`** (determination, on save/modify) — when a new book is created without a status, it is defaulted to `AVAILABLE`.
2. **`issueBook`** (custom RAP action) —
   - Reads the current book.
   - If `Status = 'AVAILABLE'` → sets `Status = 'ISSUED'`.
   - If `Status = 'ISSUED'` → the action fails and returns the message **"Book is already issued"**.
3. **`returnBook`** (custom RAP action) —
   - Reads the current book.
   - If `Status = 'ISSUED'` → sets `Status = 'AVAILABLE'`.
   - If `Status = 'AVAILABLE'` → the action fails and returns the message **"Book is not currently issued"**.

## How to Deploy (abapGit)

1. In your SAP BTP ABAP Environment / on-premise system, create (or reuse) a package, e.g. `ZLIBRARY_MGMT`.
2. Install/open **abapGit** (https://abapgit.org) in your system.
3. Choose **New Online Repository** and point it at this repository's clone URL.
4. Select your package and pull the repository — this creates all objects listed above.
5. Activate all objects (abapGit will do this automatically; if not, activate top-down: table → draft table → interface view → behavior definition → behavior class → projection view → metadata extension → status view → service definition → service binding).
6. Open the **Service Binding** `ZUI_YESH_DB_LIB_SYS_O4` in the ABAP Development Tools (Eclipse) and click **Publish**, then **Preview** to launch the Fiori Elements app in the browser.

> No abapGit installation? You can also import each object manually in ADT by creating objects with the same names/types and pasting in the corresponding source files from `/src`.

## Sample Output / Usage

1. Open the published service preview (List Report).
2. Click **Create**, enter a `BookName` and `Author`, and save — the book is created with `Status = AVAILABLE`.
3. Select a book and press the **Issue** action button:
   - If it was `AVAILABLE`, its status flips to `ISSUED`.
   - If it was already `ISSUED`, a message *"Book is already issued"* is shown and nothing changes.
4. Select an issued book and press the **Return** action button:
   - Its status flips back to `AVAILABLE`.
   - If it wasn't issued, a message *"Book is not currently issued"* is shown.

## What I learned / Challenges

Implementing business logic through RAP **actions** (instead of plain ABAP procedural logic) was the biggest learning curve — understanding how a Behavior Definition declares an action, how the Behavior Implementation class (`LHC_*`) reads entities with `READ ENTITIES`, and how `MODIFY ENTITIES` is used to change state inside an action, all took practice. Building this project strengthened my understanding of ABAP, database table design, CDS modeling, and RAP-based business logic implementation in SAP.

## License

This project is provided as-is for learning/demo purposes.

CLASS LHC_ZR_YESH_DB_LIB_SYS DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR ZrYeshDbLibSys
        RESULT result,

      setInitialStatus FOR DETERMINE ON MODIFY
        IMPORTING keys FOR ZrYeshDbLibSys~setInitialStatus,

      issueBook FOR MODIFY
        IMPORTING keys FOR ACTION ZrYeshDbLibSys~issueBook RESULT result,

      returnBook FOR MODIFY
        IMPORTING keys FOR ACTION ZrYeshDbLibSys~returnBook RESULT result.

ENDCLASS.

CLASS LHC_ZR_YESH_DB_LIB_SYS IMPLEMENTATION.

  METHOD GET_GLOBAL_AUTHORIZATIONS.
  ENDMETHOD.

  METHOD setInitialStatus.

    READ ENTITIES OF ZR_YESH_DB_LIB_SYS IN LOCAL MODE
      ENTITY ZrYeshDbLibSys
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(books).

    LOOP AT books INTO DATA(book).

      IF book-Status IS INITIAL.

        MODIFY ENTITIES OF ZR_YESH_DB_LIB_SYS IN LOCAL MODE
          ENTITY ZrYeshDbLibSys
          UPDATE FIELDS ( status )
          WITH VALUE #(
            ( %tky   = book-%tky
              status = 'AVAILABLE' )
          ).

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD issueBook.

    " Read the current data of the books that were selected for issuing
    READ ENTITIES OF ZR_YESH_DB_LIB_SYS IN LOCAL MODE
      ENTITY ZrYeshDbLibSys
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(books).

    LOOP AT books INTO DATA(book).

      IF book-Status = 'AVAILABLE'.

        " Book is free -> issue it
        MODIFY ENTITIES OF ZR_YESH_DB_LIB_SYS IN LOCAL MODE
          ENTITY ZrYeshDbLibSys
          UPDATE FIELDS ( status )
          WITH VALUE #(
            ( %tky   = book-%tky
              status = 'ISSUED' )
          ).

      ELSE.

        " Book is already issued -> raise an error message
        APPEND VALUE #( %tky = book-%tky ) TO failed-ZrYeshDbLibSys.

        APPEND VALUE #(
          %tky = book-%tky
          %msg = new_message(
            id       = 'ZMSG'
            number   = '001'
            severity = if_abap_behv_message=>severity-error
            v1       = 'Book is already issued'
          )
        ) TO reported-ZrYeshDbLibSys.

      ENDIF.

    ENDLOOP.

    " Return the (possibly updated) instance data as the action result
    READ ENTITIES OF ZR_YESH_DB_LIB_SYS IN LOCAL MODE
      ENTITY ZrYeshDbLibSys
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(updated_books).

    result = VALUE #( FOR upd_book IN updated_books
                       ( %tky   = upd_book-%tky
                         %param = upd_book ) ).

  ENDMETHOD.

  METHOD returnBook.

    " Read the current data of the books that were selected for returning
    READ ENTITIES OF ZR_YESH_DB_LIB_SYS IN LOCAL MODE
      ENTITY ZrYeshDbLibSys
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(books).

    LOOP AT books INTO DATA(book).

      IF book-Status = 'ISSUED'.

        " Book is currently issued -> mark it as returned/available
        MODIFY ENTITIES OF ZR_YESH_DB_LIB_SYS IN LOCAL MODE
          ENTITY ZrYeshDbLibSys
          UPDATE FIELDS ( status )
          WITH VALUE #(
            ( %tky   = book-%tky
              status = 'AVAILABLE' )
          ).

      ELSE.

        " Book was never issued -> raise an error message
        APPEND VALUE #( %tky = book-%tky ) TO failed-ZrYeshDbLibSys.

        APPEND VALUE #(
          %tky = book-%tky
          %msg = new_message(
            id       = 'ZMSG'
            number   = '004'
            severity = if_abap_behv_message=>severity-error
            v1       = 'Book is not currently issued'
          )
        ) TO reported-ZrYeshDbLibSys.

      ENDIF.

    ENDLOOP.

    " Return the (possibly updated) instance data as the action result
    READ ENTITIES OF ZR_YESH_DB_LIB_SYS IN LOCAL MODE
      ENTITY ZrYeshDbLibSys
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(updated_books2).

    result = VALUE #( FOR upd IN updated_books2
                       ( %tky   = upd-%tky
                         %param = upd ) ).

  ENDMETHOD.

ENDCLASS.

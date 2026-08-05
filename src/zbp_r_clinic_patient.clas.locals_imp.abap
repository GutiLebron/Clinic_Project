CLASS lhc_zr_clinic_patient DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR Patient
        RESULT result,

      get_instance_features
        FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR Patient
        RESULT result,

      DeactivatePatient FOR MODIFY
        IMPORTING keys FOR ACTION Patient~DeactivatePatient,

      ReactivatePatient FOR MODIFY
        IMPORTING keys FOR ACTION Patient~ReactivatePatient.

ENDCLASS.

CLASS lhc_zr_clinic_patient IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.
  METHOD DeactivatePatient.

    READ ENTITIES OF zr_clinic_patient
        ENTITY Patient
        FIELDS ( Active )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_patient).

    DATA lt_update TYPE TABLE FOR UPDATE zr_clinic_patient.

    LOOP AT lt_patient INTO DATA(ls_patient).
      IF ls_patient-Active = abap_true.
        APPEND VALUE #(
            %tky = ls_patient-%tky
            Active = abap_false
        ) TO lt_update.
      ELSE.
        APPEND VALUE #(
            %tky = ls_patient-%tky
         ) TO failed-patient.

        APPEND VALUE #(
            %tky = ls_patient-%tky
            %msg = new_message(
            id = 'ZMC_CLINIC_PATIENT'
            number = '002'
            severity = if_abap_behv_message=>severity-error
        )
        ) TO reported-patient.


      ENDIF.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.

      MODIFY ENTITIES OF zr_clinic_patient
          ENTITY Patient
          UPDATE
              FIELDS ( Active )
              WITH lt_update.

          LOOP AT lt_update INTO DATA(ls_update).

            APPEND VALUE #(
                %tky = ls_update-%tky
                %msg =
                    new_message(
                    id = 'ZMC_CLINIC_PATIENT'
                    number = '001'
                    severity = if_abap_behv_message=>severity-success
                    )
            ) TO reported-patient.

          ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD ReactivatePatient.

    READ ENTITIES OF zr_clinic_patient
        ENTITY Patient
        FIELDS ( Active )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_patient).

    DATA lt_update TYPE TABLE FOR UPDATE zr_clinic_patient.

    LOOP AT lt_patient INTO DATA(ls_patient).

        IF ls_patient-Active = abap_false.

            APPEND VALUE #(
                %tky = ls_patient-%tky
                Active = abap_true
             ) TO lt_update.
        ELSE.
             APPEND VALUE #(
                %tky = ls_patient-%tky
             ) TO failed-patient.

             APPEND VALUE #(
                %tky = ls_patient-%tky
                %msg = new_message(
                    id = 'ZMC_CLINIC_PATIENT'
                    number = '004'
                    severity = if_abap_behv_message=>severity-error
                )
              ) TO reported-patient.
        ENDIF.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.

        MODIFY ENTITIES OF zr_clinic_patient
            ENTITY Patient
            UPDATE
            FIELDS ( Active )
            WITH lt_update.

        LOOP AT lt_update INTO DATA(ls_update).

            APPEND VALUE #(
                %tky = ls_update-%tky
                %msg =
                    new_message(
                        id = 'ZMC_CLINIC_PATIENT'
                        number = '003'
                        severity = if_abap_behv_message=>severity-success
                    )
            ) TO reported-patient.

        ENDLOOP.

    ENDIF.

  ENDMETHOD.

  METHOD get_instance_features.
*FIRST WE READ AND STORE THEM IN A INTERNAL TABLE*
    READ ENTITIES OF zr_clinic_patient
        ENTITY Patient
        FIELDS ( Active )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_patient).

    LOOP AT lt_patient into DATA(ls_patient).
*CONDITION TO MEET INTO THE ENTITY*
        IF ls_patient-Active = abap_true.

            APPEND VALUE #(

            %tky = ls_patient-%tky
*WITH THE TECHNICAL FIELD %ACTION WE CAN ENABLE OR DISABLE ACTIONS FROM THE BEHAVIOR DEFINITION*
            %action-DeactivatePatient = if_abap_behv=>fc-o-enabled
            %action-ReactivatePatient = if_abap_behv=>fc-o-disabled

            ) TO RESULT.
        ELSE.

             APPEND VALUE #(

            %tky = ls_patient-%tky

            %action-DeactivatePatient = if_abap_behv=>fc-o-disabled
            %action-ReactivatePatient = if_abap_behv=>fc-o-enabled

            ) TO RESULT.

        ENDIF.

    ENDLOOP.


  ENDMETHOD.

ENDCLASS.

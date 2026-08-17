CLASS lsc_zr_clinic_doctor DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zr_clinic_doctor IMPLEMENTATION.

  METHOD save_modified.



  ENDMETHOD.

ENDCLASS.

CLASS lhc_zr_clinic_doctor DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR Doctor
        RESULT result,

      get_instance_features
        FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR Doctor
        RESULT result,

*CUSTOM METHODS*
      DeactivateDoctor
        FOR MODIFY
        IMPORTING keys FOR ACTION Doctor~DeactivateDoctor,

      ReactivateDoctor
        FOR MODIFY
        IMPORTING keys FOR ACTION Doctor~ReactivateDoctor,

      AddSpecialty
        FOR MODIFY
        keys FOR ACTION Doctor~AddSpecialty.
ENDCLASS.

CLASS lhc_zr_clinic_doctor IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.

*DEACTIVATE METHOD*
  METHOD DeactivateDoctor.
*FIRST WE READ AND STORE THEM IN A INTERNAL TABLE*
    READ ENTITIES OF zr_clinic_doctor
        ENTITY Doctor
        FIELDS ( Active )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_doctor).

    DATA lt_update TYPE TABLE FOR UPDATE zr_clinic_doctor.

*LOOP THROUGHT INTERNAL TABLE THE STORED ENTITIES*
    LOOP AT lt_doctor INTO DATA(ls_doctor).

*TAKE ENTITIES TO MODIFY IN A INTERNAL TABLE TO MODIFIY, JUST THE ENTITIES WHO MEET CONDITIONS*
      IF ls_doctor-Active = abap_true.
        APPEND VALUE #(
            %tky = ls_doctor-%tky
            Active = abap_false
        ) TO lt_update.
      ELSE.
*USE FAILED STRUCTURE TO STORE THE ENITIES THAT DO NOT MEET THE CONTITIONS IN OTHER INTERNAL TABLE *
        APPEND VALUE #(
            %tky = ls_doctor-%tky
        ) TO failed-doctor.
*ADD ERROR MESSAGES TO REPORTED STRUCTURE*
        APPEND VALUE #(
            %tky = ls_doctor-%tky
            %msg =
                new_message(
                id = 'ZMC_CLINIC_DOCTOR'
                number = '002'
                severity = if_abap_behv_message=>severity-error
                )
        ) TO reported-doctor.
      ENDIF.
    ENDLOOP.
*IF THE INTERNAL TABLE TO UPDATE IS NOT EMPTY WE PROCEED TO DO THE MODIFY*
    IF lt_update IS NOT INITIAL.

      MODIFY ENTITIES OF zr_clinic_doctor
          ENTITY Doctor
              UPDATE
                  FIELDS ( Active )
                  WITH lt_update.
*AFTER THE UPDATE RETURN THE SUCCESS MESSAGES*
      LOOP AT lt_update INTO DATA(ls_update).

        APPEND VALUE #(
            %tky = ls_update-%tky
            %msg =
                new_message(
                id = 'ZMC_CLINIC_DOCTOR'
                number = '001'
                severity = if_abap_behv_message=>severity-success
                )
        ) TO reported-doctor.

      ENDLOOP.
    ENDIF.

  ENDMETHOD.

*REACTIVATE METHOD*
  METHOD ReactivateDoctor.

    READ ENTITIES OF zr_clinic_doctor
      ENTITY Doctor
      FIELDS ( Active )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_doctor).

    DATA lt_update TYPE TABLE FOR UPDATE zr_clinic_doctor.

    LOOP AT lt_doctor INTO DATA(ls_doctor).

      IF ls_doctor-Active = abap_false.
        APPEND VALUE #(
            %tky = ls_doctor-%tky
            Active = abap_true
        ) TO lt_update.
      ELSE.
        APPEND VALUE #(
            %tky = ls_doctor-%tky
        ) TO failed-doctor.

        APPEND VALUE #(
            %tky = ls_doctor-%tky
            %msg =
                   new_message(
                    id = 'ZMC_CLINIC_DOCTOR'
                    number = '004'
                    severity = if_abap_behv_message=>severity-error
                   )
        ) TO reported-doctor.

      ENDIF.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.

      MODIFY ENTITIES OF zr_clinic_doctor
          ENTITY Doctor
          UPDATE
              FIELDS ( Active )
              WITH lt_update.

      LOOP AT lt_update INTO DATA(ls_update).

        APPEND VALUE #(
            %tky = ls_update-%tky
            %msg =
                    new_message(
                        id = 'ZMC_CLINIC_DOCTOR'
                        number = '003'
                        severity = if_abap_behv_message=>severity-success
                    )
         ) TO reported-doctor.

      ENDLOOP.
    ENDIF.

  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF zr_clinic_doctor
        ENTITY Doctor
        FIELDS ( Active )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_doctor).

    LOOP AT lt_doctor INTO DATA(ls_doctor).
        IF ls_doctor-Active = abap_true.

            APPEND VALUE #(

                %tky = ls_doctor-%tky
                %action-DeactivateDoctor = if_abap_behv=>fc-o-enabled
                %action-ReactivateDoctor = if_abap_behv=>fc-o-disabled

            ) TO result.
        ELSE.
            APPEND VALUE #(

                %tky = ls_doctor-%tky
                %action-DeactivateDoctor = if_abap_behv=>fc-o-disabled
                %action-ReactivateDoctor = if_abap_behv=>fc-o-enabled

            ) TO result.

        ENDIF.
    ENDLOOP.


  ENDMETHOD.

  METHOD AddSpecialty.

  LOOP AT keys INTO DATA(ls_keys).

    DATA(lv_doctor_uuid) = ls_keys-DoctorUUID.
    DATA(lv_spec_uuid) = ls_keys-%param-SpecUUID.

*CHECK IF SPEC EXISTS AND IS ACTIVE
        READ ENTITIES OF zr_clinic_spec
            ENTITY Spec
            FIELDS ( Specuuid Active )
            WITH VALUE #(
                (
                    %key-Specuuid = lv_spec_uuid
                )

            ) RESULT DATA(lt_spec).

        IF lt_spec IS INITIAL
            OR ( lt_spec IS NOT INITIAL AND lt_spec[ 1 ]-Active = abap_false ).

            APPEND VALUE #(
                %tky = ls_keys-%tky
            ) TO failed-doctor.

            APPEND VALUE #(

                %tky = ls_keys-%tky
                %msg = new_message(
                    id = 'ZMC_CLINIC_DOCTOR'
                    number = '005'
                    severity = if_abap_behv_message=>severity-error
                )

            ) TO reported-doctor.

            CONTINUE.

        ENDIF.

*CHECK IF THE RELATIONSHIP ALREADY EXISTS

        SELECT SINGLE
            FROM zr_clinic_doc_spec
            FIELDS  Specuuid,
                    Doctoruuid
            WHERE   Specuuid = @lv_spec_uuid
                    AND Doctoruuid = @lv_doctor_uuid
            INTO    @DATA(ls_doc_spec).

*CATCH THE ERROR IF THE SELECT WAS WRONG
        IF sy-subrc = 0.

            APPEND VALUE #(
                %tky = ls_keys-%tky
            ) TO failed-doctor.
*SEND THE MESSAGE ERROR
            APPEND VALUE #(
                %tky = ls_keys-%tky
                %msg = new_message(
                    id = 'ZMC_CLINIC_DOCTOR'
                    number = '006'
                    severity = if_abap_behv_message=>severity-error
                 )
             ) TO reported-doctor.

             CONTINUE.

        ENDIF.

        DATA(lv_cid) = |DOCSPEC_{ lv_spec_uuid }|.
*CREATE THE NEW REGISTRY
        MODIFY ENTITIES OF zr_clinic_doctor
            ENTITY Doctor
            CREATE BY \_DocSpec
            FIELDS ( Specuuid )
            WITH VALUE #(
                (
                    %tky = ls_keys-%tky
                    %target = VALUE #(
                        (
                            %cid = lv_cid
                            Specuuid = lv_spec_uuid
                        )
                    )
                )
            )
            failed DATA(lt_failed)
            reported DATA(lt_reported).

         IF lt_failed IS NOT INITIAL.

            APPEND VALUE #(
                %tky = ls_keys-%tky
            ) TO failed-doctor.

            CONTINUE.

         ENDIF.

*SEND A SUCCESFULL MESSAGE
         APPEND VALUE #(

            %tky = ls_keys-%tky
            %msg = new_message(
                id = 'ZMC_CLINIC_DOCTOR'
                number = '007'
                severity = if_abap_behv_message=>severity-success
            )

         ) TO reported-doctor.

  ENDLOOP.

  ENDMETHOD.

ENDCLASS.

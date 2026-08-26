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
        keys FOR ACTION Doctor~AddSpecialty,

      RemoveSpecialty
        FOR MODIFY
        keys FOR ACTION Doctor~RemoveSpecialty,

      GenerateAvailability
        FOR MODIFY
        keys FOR ACTION Doctor~GenerateAvailability
        RESULT result.

ENDCLASS.

CLASS lhc_zr_clinic_doctor IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.

*DEACTIVATE METHOD*
  METHOD DeactivateDoctor.
*FIRST WE READ AND STORE THEM IN A INTERNAL TABLE*
    READ ENTITIES OF zr_clinic_doctor
        IN LOCAL MODE
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
          IN LOCAL MODE
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
      IN LOCAL MODE
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
          IN LOCAL MODE
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
        IN LOCAL MODE
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
            IN LOCAL MODE
            ENTITY Doctor
            CREATE BY \_DocSpec  "<-CREAMOS EN LA TABLA DOCTOR-SPECIALITY"
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

  METHOD RemoveSpecialty.

    LOOP AT keys INTO DATA(ls_keys).

    DATA(lv_Doctoruuid) = ls_keys-DoctorUUID.
    DATA(lv_Specuuid) = ls_keys-%param-SpecUUID.

*CHECK REGISTRY WITH DOCTORUUID AND SPECUUID EXISTS
        READ ENTITIES OF zr_clinic_doctor
            IN LOCAL MODE
            ENTITY DocSpec
            FIELDS ( Doctoruuid Specuuid )
            WITH VALUE #(
                (
                    %key-Doctoruuid = lv_doctoruuid
                    %key-Specuuid = lv_specuuid
                )
            ) RESULT DATA(lt_DocSpec).
*REGISTRY NOT EXISTS
        IF lt_DocSpec IS INITIAL.

            APPEND VALUE #(
                %tky = ls_keys-%tky
            ) TO failed-doctor.

            APPEND VALUE #(
                %tky = ls_keys-%tky
                %msg = new_message(
                    id = 'ZMC_CLINIC_DOCTOR'
                    number = '008'
                    severity = if_abap_behv_message=>severity-error
                )
            ) TO reported-doctor.

            CONTINUE.

        ENDIF.
*TAKE THE TECHNICAL KEY FROM THE FIRST IN THE LT_DOCSPEC TABLE
        DATA(lv_delete_tky) = lt_DocSpec[ 1 ]-%tky.
*DELETE THE REGISTER WITH THE TKY
        MODIFY ENTITIES OF zr_clinic_doctor
            IN LOCAL MODE
            ENTITY DocSpec
            DELETE FROM VALUE #(
                (
                    %tky = lv_delete_tky

                 )
             )
             FAILED DATA(lt_failed)
             REPORTED DATA(lt_reported).

        IF lt_failed IS NOT INITIAL.
            APPEND VALUE #(
                %tky = ls_keys-%tky
            ) TO failed-doctor.

            CONTINUE.
        ENDIF.

        APPEND VALUE #(
            %tky = ls_keys-%tky
            %msg = new_message(
                id = 'ZMC_CLINIC_DOCTOR'
                number = '009'
                severity = if_abap_behv_message=>severity-success
            )
        ) TO reported-doctor.


    ENDLOOP.

  ENDMETHOD.

*METHOD TO GENERATE DATE SLOTS TO ACTIVE DOCTORS
  METHOD GenerateAvailability.

    DATA lv_cid_counter TYPE i VALUE 0.
    DATA lt_create TYPE TABLE FOR CREATE zr_clinic_date.

    LOOP AT keys into DATA(ls_keys).

*CATCH PARAMETER DATE IN A VARIABLE
    DATA(lv_date) = ls_keys-%param-appointment_date.
    DATA(lv_doc)  = ls_keys-%tky-DoctorUUID.
    DATA(lv_today) = cl_abap_context_info=>get_system_date(  ).

        IF lv_date IS INITIAL OR lv_date <= lv_today.

            APPEND VALUE #(
                %tky = ls_keys-%tky
            ) TO failed-doctor.

            APPEND VALUE #(
                    %tky = ls_keys-%tky
                    %msg = new_message(
                    id = 'ZMC_CLINIC_DOCTOR'
                    number = '010'
                    severity = if_abap_behv_message=>severity-error
                    )
             ) TO reported-doctor.
           CONTINUE.
        ENDIF.

*DAY OF THE WEEK OPEN
            DATA(lv_weekday) = CONV i( lv_date - '19000101' ) MOD 7.

            IF lv_weekday = 0.

                APPEND VALUE #(
                    %tky = ls_keys-%tky
                ) TO failed-doctor.


                APPEND VALUE #(
                    %tky = ls_keys-%tky
                    %msg = new_message(
                        id = 'ZMC_CLINIC_DOCTOR'
                        number = '011'
                        severity = if_abap_behv_message=>severity-error
                    )
                ) TO reported-doctor.
              CONTINUE.
            ENDIF.

*DOCTOR IS ACTIVE
        READ ENTITIES OF zr_clinic_doctor
            IN LOCAL MODE
            ENTITY Doctor
            FIELDS ( Active )
            WITH VALUE #(
                (
                %tky = ls_keys-%tky
                 )
             )
            RESULT DATA(lt_doctor).

            IF lt_doctor IS INITIAL
            OR lt_doctor[ 1 ]-Active = abap_false.

                APPEND VALUE #(
                    %tky = ls_keys-%tky
                ) TO failed-doctor.

                APPEND VALUE #(
                    %tky = ls_keys-%tky
                    %msg = new_message(
                        id = 'ZMC_CLINIC_DOCTOR'
                        number = '002'
                        severity = if_abap_behv_message=>severity-error
                    )
                ) TO reported-doctor.
               CONTINUE.
            ENDIF.
*DOCTOR ALREADY HAS DATE THIS DAY

           SELECT FROM zclinic_date
            FIELDS dateuuid
            WHERE Doctoruuid = @lv_doc
                AND appointment_date = @lv_date
            INTO TABLE @DATA(lt_date_doctor).


                IF lt_date_doctor IS NOT INITIAL.

                    APPEND VALUE #(
                        %tky = ls_keys-%tky
                    ) TO failed-doctor.

                    APPEND VALUE #(
                        %tky = ls_keys-%tky
                        %msg = new_message(
                            id = 'ZMC_CLINIC_DOCTOR'
                            number = '012'
                            severity = if_abap_behv_message=>severity-error
                        )
                    ) TO reported-doctor.

                  CONTINUE.
                ENDIF.

*GENERATE DATES FOR ACTIVE DOCTOR
    DATA lv_time TYPE t VALUE '080000'.
    DATA ls_new_date TYPE zclinic_date.

    DATA lt_new_dates TYPE STANDARD TABLE OF zclinic_date.
*
**CLEAR VARIABLES
*    CLEAR lv_time.
*    CLEAR lt_new_dates.

          WHILE lv_time < '190000'.

          CLEAR ls_new_date.

            ls_new_date-appointment_date = lv_date.
            ls_new_date-appointment_time = lv_time.
            ls_new_date-appointment_status = 'OPEN'.
            ls_new_date-appointment_type = 'N'.
            ls_new_date-doctoruuid = lv_doc.

          APPEND ls_new_date TO lt_new_dates.


          lv_time = lv_time + 1800.

          ENDWHILE.

          LOOP AT lt_new_dates INTO ls_new_date.

            lv_cid_counter += 1.

            APPEND VALUE #(
                %cid = |CREATE_{ lv_cid_counter }|
                Doctoruuid = ls_new_date-doctoruuid
                AppointmentDate = ls_new_date-appointment_date
                AppointmentTime = ls_new_date-appointment_time
                AppointmentStatus = ls_new_date-appointment_status
                AppointmentType = ls_new_date-appointment_type

            ) TO lt_create.

          ENDLOOP.


    ENDLOOP.

        IF lt_create IS NOT INITIAL.

            MODIFY ENTITIES OF zr_clinic_date
                ENTITY Date
                CREATE
                FIELDS ( Doctoruuid AppointmentDate AppointmentTime AppointmentStatus AppointmentType )
                WITH lt_create
                MAPPED   DATA(mapped_date)
                FAILED   DATA(failed_date)
                REPORTED DATA(reported_date).

            failed-doctor   =
                CORRESPONDING #(
                    BASE ( failed-doctor )
                        failed_date-date ).

            reported-doctor =
                CORRESPONDING #(
                    BASE ( reported-doctor )
                        reported_date-date ).

            IF reported_date-date IS NOT INITIAL.

                APPEND VALUE #(
                    %tky = ls_keys-%tky
                ) TO failed-doctor.

                APPEND VALUE #(
                    %tky = ls_keys-%tky
                    %msg = new_message(
                        id = 'ZMC_CLINIC_DOCTOR'
                        number = '013'
                        severity = if_abap_behv_message=>severity-error
                    )

                ) TO reported-doctor.

            ENDIF.

            APPEND VALUE #(
                %tky = ls_keys-%tky
                %msg = new_message(
                id = 'ZMC_CLINIC_DOCTOR'
                number = '014'
                severity = if_abap_behv_message=>severity-success
                v1 = lv_cid_counter
                 )
             ) TO reported-doctor.

        ENDIF.


  ENDMETHOD.

ENDCLASS.

CLASS LHC_ZR_CLINIC_SPEC DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:

      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR Spec
        RESULT result,

      get_instance_features
        FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR Spec
        RESULT result,
      DeactivateSpec FOR MODIFY
            IMPORTING keys FOR ACTION Spec~DeactivateSpec,

      ReactivateSpec FOR MODIFY
            IMPORTING keys FOR ACTION Spec~ReactivateSpec.
ENDCLASS.

CLASS LHC_ZR_CLINIC_SPEC IMPLEMENTATION.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
  ENDMETHOD.
  METHOD DeactivateSpec.

  READ ENTITIES OF zr_clinic_spec
  ENTITY Spec
  FIELDS ( Active )
  WITH CORRESPONDING #( keys )
  RESULT DATA(lt_spec).

  DATA lt_update TYPE TABLE FOR UPDATE zr_clinic_spec.

  LOOP AT lt_spec INTO DATA(ls_spec).

  IF ls_spec-Active = abap_true.

    APPEND VALUE #(
        %tky = ls_spec-%tky
        Active = abap_false
    ) to lt_update.

  ELSE.

    APPEND VALUE #(
        %tky = ls_spec-%tky
    ) TO failed-spec.

    APPEND VALUE #(
        %tky = ls_spec-%tky
        %msg =
            new_message(
            id = 'ZMC_CLINIC_SPEC'
            number = '002'
            severity = if_abap_behv_message=>severity-error
            )
    ) TO reported-spec.

  ENDIF.

  ENDLOOP.

  IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zr_clinic_spec
        ENTITY Spec
            UPDATE
                FIELDS ( Active )
                WITH lt_update.

      LOOP AT lt_update INTO DATA(ls_update).

        APPEND VALUE #(
            %tky = ls_update-%tky
            %msg = new_message(
                id = 'ZMC_CLINIC_SPEC'
                number = '001'
                severity = if_abap_behv_message=>severity-success
            )
        ) TO reported-spec.

      ENDLOOP.
  ENDIF.

  ENDMETHOD.

  METHOD ReactivateSpec.

  READ ENTITIES OF zr_clinic_spec
  ENTITY Spec
  FIELDS ( Active )
  WITH CORRESPONDING #( keys )
  RESULT DATA(lt_spec).

  DATA lt_update TYPE TABLE FOR UPDATE zr_clinic_spec.

  LOOP AT lt_spec INTO DATA(ls_spec).

    IF ls_spec-Active = abap_false.

        APPEND VALUE #(
        %tky = ls_spec-%tky
        Active = abap_true
        ) TO lt_update.

    ELSE.

        APPEND VALUE #(
        %tky = ls_spec-%tky
        ) TO failed-spec.

        APPEND VALUE #(
            %tky = ls_spec-%tky
            %msg = new_message(
                id = 'ZMC_CLINIC_SPEC'
                number = '004'
                severity = if_abap_behv_message=>severity-error
            )
        ) TO reported-spec.

    ENDIF.


  ENDLOOP.


    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zr_clinic_spec
        ENTITY Spec
            UPDATE
                FIELDS ( Active )
                WITH lt_update.

      LOOP AT lt_update INTO DATA(ls_update).

        APPEND VALUE #(
            %tky = ls_update-%tky
            %msg = new_message(
            id = 'ZMC_CLINIC_SPEC'
            number = '003'
            severity = if_abap_behv_message=>severity-success
            )
        ) TO reported-Spec.

      ENDLOOP.

    ENDIF.


  ENDMETHOD.

  METHOD GET_INSTANCE_FEATURES.

    READ ENTITIES OF zr_clinic_spec
        ENTITY Spec
        FIELDS ( Active )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_spec).

   LOOP AT lt_spec INTO DATA(ls_spec).

    IF ls_spec-Active = abap_true.

        APPEND VALUE #(
            %tky = ls_spec-%tky
            %action-DeactivateSpec = if_abap_behv=>fc-o-enabled
            %action-ReactivateSpec = if_abap_behv=>fc-o-disabled
        ) TO result.

    ELSE.

        APPEND VALUE #(
            %tky = ls_spec-%tky
            %action-DeactivateSpec = if_abap_behv=>fc-o-disabled
            %action-ReactivateSpec = if_abap_behv=>fc-o-enabled
        ) TO result.

    ENDIF.

   ENDLOOP.
  ENDMETHOD.

ENDCLASS.

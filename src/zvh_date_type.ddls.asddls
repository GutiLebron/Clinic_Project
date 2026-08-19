@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value help para date_type'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZVH_DATE_TYPE 
    as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T
    ( p_domain_name: 'ZD_CLINIC_DATE_TYPE' ) as Text
{
    @UI.lineItem: [{  position : 10  }]
    key Text.value_position as ValuePosition,
    @UI.lineItem: [{  position : 20  }]
    key Text.value_low as ValueLow,
    
    @UI.hidden: true
    key Text.domain_name as DomainName,
    
    @Semantics.text: true
    @UI.lineItem: [{  position : 30  }]
    Text.text           as Description
}

    where 
    
        Text.language = $session.system_language

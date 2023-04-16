final String engineerUser = '{"submodel": "engineer", "user": {'
    '"id": 1, "email": "bla@bla.com", "username": "bla", "full_name": "", "first_name": "", "last_name": "",'
    '"engineer": {"address": "", "postal": "", "city":"", "country_code": "NL", "mobile": "", "prefered_location": 1}'
    '}}';

final String assignedOrderMaterial = '{"id": 1, "assignedOrderId": 1, "material": 1, "location": 1, "amount": 3.00}';

final String memberPictures = '{"next": null, "previous": null, "count": 1, "num_pages": 1, "results": [{"name": "bla", "picture": "bla.jpg"}]}';

final String assignedOrderActivity = '{"id":129,"assigned_order":309,"work_start":"10:40:00",'
    '"work_end":"16:50:00","travel_to":"01:05:00","travel_back":"02:25:00",'
    '"distance_to":25,"distance_back":50,"activity_date":"18/01/2023","extra_work":"00:35:00",'
    '"extra_work_description":"Test","distance_fixed_rate_amount":0,"actual_work":"06:00:00"}';

final String assignedOrderDocument = '{"id": 1, "assigned_order": 1, "name": "grappig.png", "description": "", "document": "grappig.png"}';

final String orderDocument = '{"id": 1, "order": 1, "name": "grappig.png", "description": "", "document": "grappig.png"}';

final String assignedOrder = '{"id": 1, "engineer_id": 1, "order": {"id": 1, '
    '"uuid": "38b41c8c-0f9e-401e-b341-80985852a210", "customer_id": "1234", "order_id": "m1_order_id1", '
    '"service_number": null, "order_reference": null, "order_type": "test", "customer_remarks": null, '
    '"description": null, "start_date": "28/03/2023", "start_time": null, "end_date": "28/03/2023",'
    ' "end_time": null, "order_date": "28/03/2023", "last_status": "no status found", "last_status_full": '
    '"no status found", "remarks": null, "order_name": "test", "order_address": "test 1",'
    ' "order_postal": "1234AA", "order_city": "bla", "order_country_code": "NL", "order_tel": "0612345678",'
    ' "order_mobile": "0612345678", "order_email": "bla@bla.com", "order_contact": "henk", "created": "28/03/2023 09:39", '
    '"documents": [], "orderlines": [], "workorder_pdf_url": "", "total_price_purchase": "0.00", '
    '"total_price_selling": "0.00", "customer_relation": null, "customer_rate_avg": "-", '
    '"required_assigned": "1/1 (100.00%)", "required_users": 1, "user_order_available_set_count": 0, '
    '"assigned_count": 1, "workorder_url": "https://companycode1.my24service.com:8000/#/orders/orders/workorder/38b41c8c-0f9e-401e-b341-80985852a210",'
    ' "workorder_pdf_url_partner": "", "customer_order_accepted": true, "workorder_documents": [],'
    ' "infolines": [], "statusses": [], "maintenance_product_lines": [], "branch": null}, "is_started": false,'
    ' "is_ended": false, "is_signed": false,'
    ' "start_codes": [{"id": 1, "statuscode": "Start", "description": "Start"}],'
    ' "end_codes": [{"id": 2, "statuscode": "End", "description": "End"}], "after_end_order_codes": [], '
    '"assigned_userdata": [{"full_name": "bla", "date": "28/03/2023", "mobile": "None"}], '
    '"after_end_reports": [], "customer": {}, "assignedorder_date": "28/03/2023"}';

final String order = '{"id":506,"uuid":"f194abef-04dc-4874-ac79-38b6c1204849","customer_id":"1263","order_id":"10603","service_number":null,'
    '"order_reference":"","order_type":"Onderhoud","customer_remarks":"","description":null,"start_date":"17/03/2023","start_time":null,'
    '"end_date":"17/03/2023","end_time":null,"order_date":"17/03/2023","last_status":"Workorder signed",'
    '"last_status_full":"17/03/2023 11:52 Workorder signed","remarks":null,"order_name":"Fictie B.V.","order_address":"Metaalweg 4",'
    '"order_postal":"3751LS","order_city":"Bunschoten-Spakenburg","order_country_code":"NL","order_tel":"0650008","order_mobile":"+31610344871",'
    '"order_email":null,"order_contact":"L. Welling","created":"15/03/2023 11:44","documents":[],"statusses":[{"id":1590,"order":506,'
    '"status":"Aangemaakt door planning","modified":"15/03/2023 11:44","created":"15/03/2023 11:44"},{"id":1594,"order":506,'
    '"status":"Opdracht toegewezen aan mv","modified":"17/03/2023 11:40","created":"17/03/2023 11:40"},{"id":1595,"order":506,'
    '"status":"Begin opdracht gemeld door mv","modified":"17/03/2023 11:40","created":"17/03/2023 11:40"},{"id":1596,"order":506,'
    '"status":"Opdracht klaar gemeld door mv","modified":"17/03/2023 11:43","created":"17/03/2023 11:43"},{"id":1597,"order":506,'
    '"status":"Workorder signed","modified":"17/03/2023 11:52","created":"17/03/2023 11:52"}],"orderlines":[{"id":1311,"product":"df",'
    '"location":"df","remarks":"df","price_purchase":"0.00","price_selling":"0.00","amount":0,"material_relation":null,'
    '"location_relation_inventory":null,"purchase_order_material":null}],'
    '"workorder_pdf_url":"https://demo.my24service-dev.com/media/workorders/demo/workorder-demo-10603.pdf","total_price_purchase":"0.00",'
    '"total_price_selling":"0.00","customer_relation":1167,"customer_rate_avg":null,"required_assigned":"1/1 (100.00%)","required_users":1,'
    '"user_order_available_set_count":0,"assigned_count":1,'
    '"workorder_url":"https://demo.my24service-dev.com/#/orders/orders/workorder/f194abef-04dc-4874-ac79-38b6c1204849",'
    '"workorder_pdf_url_partner":"","customer_order_accepted":true,"workorder_documents":[],"workorder_documents_partners":[],'
    '"infolines":[{"id":66,"info":"sd"}],"assigned_user_info":[{"full_name":"Melissa Vedder","license_plate":""}],'
    '"maintenance_product_lines":[],"reported_codes_extra_data":[],"branch":null}';

final String orderTypes = '["Storing","Reparatie","Onderhoud","Klein onderhoud","Groot onderhoud","2 verdiepingen","Trap mal"]';

final String customerHistoryOrder = '{"id": 2,'
    ' "order_id": "CjyRbcAwpVpbdJhsgSiayEWQdxRYkLWRJtuIjwJfJpwcDuEFoRaNRkqHqUuN", "order_date": "30/03/2023", "order_type": '
    '"test", "order_reference": "123456", "workorder_pdf_url": "", "workorder_pdf_url_partner": "", "last_status": "Workorder signed", '
    '"last_status_full": "17/03/2023 11:52 Workorder signed", "orderlines": [{"id":1311,"product":"df","location":"df","remarks":"df",'
    '"price_purchase":"0.00","price_selling":"0.00","amount":0,"material_relation":null,"location_relation_inventory":null,'
    '"purchase_order_material":null}]}';

final String workorderSignData = '{"order": {"id": 234, "uuid": "9207f7ea-e5d9-4fed-8528-68df4fe9b5f2",'
    ' "customer_id": "4321", "order_id": "m1_order_id1", "service_number": null, "order_reference": "12345",'
    ' "order_type": "test", "customer_remarks": null, "description": null, "start_date": "01/04/2023", '
    '"start_time": null, "end_date": "01/04/2023", "end_time": null, "order_date": "01/04/2023", '
    '"last_status": "no status found", "last_status_full": "no status found", "remarks": null, '
    '"order_name": "bla", "order_address": "bla 1", "order_postal": "1234AA",'
    ' "order_city": "bla", "order_country_code": "NL", "order_tel": null, "order_mobile": null,'
    ' "order_email": null, "order_contact": null, "created": "01/04/2023 13:13", "documents": [], '
    '"orderlines": [], "workorder_pdf_url": "", "total_price_purchase": "0.00", '
    '"total_price_selling": "0.00", "customer_relation": null, "customer_rate_avg": "-",'
    ' "required_assigned": "1/1 (100.00%)", "required_users": 1, "user_order_available_set_count": 0,'
    ' "assigned_count": 1, "workorder_url": "https://companycode1.my24service.com:8000/#/orders/orders/workorder/9207f7ea-e5d9-4fed-8528-68df4fe9b5f2",'
    ' "workorder_pdf_url_partner": "", "customer_order_accepted": true, "workorder_documents": [],'
    ' "infolines": [], "statusses": [], "maintenance_product_lines": [], "branch": null}, "member": {"id": 1,'
    ' "companycode": "companycode1", "name": "RDTSwVBpkZ", "address": "EnzkSVHgpV", "tel": "ZWSgorypdi", '
    '"fax": null, "www": "http://www.domain-0.com", "postal": "txNbmaEWQ", "city": "cuhRuZROmZNvPDM",'
    ' "country_code": "Ud", "email": "person0@example.com", "contract_text": "bla (quotations (1))", '
    '"contract": 1, "contacts": "byCUZKuxpq", "is_deleted": false, "member_type": "maintenance", '
    '"companylogo": null, "companylogo_url": "/media/default_logo.jpg", "companylogo_workorder": null,'
    ' "companylogo_workorder_url": null, "activities": "bla", "info": "bla bla", "is_public": true,'
    ' "has_api_users": false, "has_branches": false, "created": "28/03/2023 09:38",'
    ' "modified": "01/04/2023 13:13"}, "user_pk": 616, "assigned_order_workorder_id": 1001,'
    ' "assigned_order_id": 132, "assigned_order_activity": [{"date": "01/04/2023", "full_name": "bla bla",'
    ' "work_start": "04:00", "work_end": "08:00", "travel_to": "02:00", "travel_back": "03:00",'
    ' "distance_to": 426, "distance_back": 499, "distance_fixed_rate_amount": 0}, {"date": "01/04/2023", '
    '"full_name": "bla bla", "work_start": "04:00", "work_end": "08:00", "travel_to": "02:00", '
    '"travel_back": "03:00", "distance_to": 477, "distance_back": 327, "distance_fixed_rate_amount": 0}],'
    ' "assigned_order_activity_totals": {"work_total": "08:00", "travel_to_total": "04:00", '
    '"travel_back_total": "06:00", "distance_to_total": 903, "distance_back_total": 826, '
    '"distance_fixed_rate_amount_total": 0}, "assigned_order_materials": [{"name": "bla",'
    ' "identifier": "bla 1", "amount": 5.0}, {"name": "bla", "identifier": "bla 2", "amount": 17.0}, {'
    '"name": "bla", "identifier": "bla 3", "amount": 16.0}], "assigned_order_extra_work": [], '
    '"assigned_order_extra_work_totals": {"extra_work": "00:00"}}';

final String workorderData = '{"id": 7, "assigned_order": 135, "signature_user": null,'
    ' "signature_name_user": null, "signature_engineer": "http://companycode1.my24service.com/media/signatures/companycode1/engineer-m1_order_id1-237.png",'
    ' "signature_name_engineer": "oh hai engineer", "signature_customer": "http://companycode1.my24service.com/media/signatures/companycode1/customer-m1_order_id1-237.png",'
    ' "signature_name_customer": "oh hai customer", "description_work": null, "assigned_order_workorder_id": "1001",'
    ' "customer_emails": null, "equipment": null}';

final String locationsData = '{"next":null,"previous":null,"count":2,"num_pages":1,"results":[{"id":2,"identifier":"CM","name":"Centraal magazijn","inventory":0,"show_in_stats":false,"created":"12/04/2023 15:59","modified":"12/04/2023 15:59"},{"id":1,"identifier":"loc1","name":"Locatie 1","inventory":0,"show_in_stats":false,"created":"12/04/2023 15:59","modified":"12/04/2023 15:59"}]}';

final String locationsInventoryData = '[{"material_id": 161, "material_name": "material 1", "material_identifier": "UkMzSFNHyZrMyZkSWgbhxBJUVLptZOiYzlLWXgPAmjgrJuXNOjNKviFTgPLuVEtOWaAQyoRiPccVCTdWnfUdxJvzhQiCmtZRyEEPMaDlaYFYyQklTnrFGvJLlPLYxvdrUrRCnVKZUCnHVTNJHlbGRerykNNLXzFzjIVfyTZGmcHePiEMVibFIxuqhRQyNYhWlmNXELbQHXyzLRRSCJCkMhktdhLIxcxfFOUEXywhUbzFhVlodKPwwKGkpmsGSvi", "supplier_name": "supplier 1", "total_amount": 50, "num_sold_today": 0, "price_purchase": "1.00", "price_selling": "3.50", "price_selling_alt": "0.00"}, {"material_id": 162, "material_name": "material 2", "material_identifier": "PpRQUuGqGNfHpiRLFIJwABSNDvkogkTmThPoGqOhEMjzqtBmSjROkOsLjHLhvDyldQeDRsWiewnOhIpXWfxyqfuTPNVKPCTnhGCiomgoUwpjrhVxBEERHfSspNJVpuhdXnDPMzTZfqwjgTkWCayWvpARRSWuksiPMvSYJuveenoSxcbPcgUsQsjEZyGsgKLbaRbQWOMrNRRMWUTDabuvdeJIvDgWzYUmCJPhVUeVJuShtrOLRUOSQOnTyEehHqo", "supplier_name": "supplier 1", "total_amount": 50, "num_sold_today": 0, "price_purchase": "1.00", "price_selling": "3.50", "price_selling_alt": "0.00"}]';

final String customerData = '{"id":1167,"name":"Fictie B.V.","address":"Metaalweg 4","postal":"3751LS","city":"Bunschoten-Spakenburg","country_code":"NL","tel":"0650008","email":"lars.welling97@yahoo.com","contact":"L. Welling","mobile":"+31610344871","time":null,"time2":null,"timealt":null,"timealt2":null,"remarks":"","customer_id":"1263","created":"25/03/2021 12:28","modified":"25/10/2022 13:52","external_identifier":"","products":[],"documents":[],"products_without_tax":false,"maintenance_contract":"","standard_hours_hour":0,"standard_hours_minute":0,"standard_hours_txt":"0:00","rating_avg":null,"branch_id":null,"branch_partner":null,"branch_view":null,"use_branch_address":true,"num_orders":105}';

final String customerOrderHistoryData = '{"next": null, "previous": null, "count": 1, "num_pages": 1, "results": [{"id": 471, "order_id": "peWguHublutMpUrKSSKBguVKhEdVUFNgIjjrhTHRvWyLiFFHFEAvtCygkHZs", "order_date": "13/04/2023", "order_type": "test", "order_reference": null, "workorder_pdf_url": "", "workorder_pdf_url_partner": "", "last_status": null, "last_status_full": "no status found", "orderlines": []}]}';

final String projectData = '{"id": 59, "name": "test", "created": "2023-04-14T09:06:35.665473", "modified": "2023-04-14T09:06:35.665480"}';

final String userWorkhoursData = '{"id": 69, "project": 94, "project_name": "test", "user": 1958, "username": "henk", "full_name": "henk test", "work_start": "07:00", "work_end": "15:00", "travel_to": "02:00", "travel_back": "01:00", "distance_to": 128, "distance_back": 337, "start_date": "14/04/2023", "description": null, "created": "14/04/2023 11:47", "modified": "14/04/2023 11:47"}';

final String leaveTypeData = '{"id": 57, "name": "vakantie", "counts_as_leave": true, "created": "2023-04-16T09:51:58.468194", "modified": "2023-04-16T09:51:58.468205"}';

<%
    ui.decorateWith("appui", "standardEmrPage")

    ui.includeCss("mirebalais", "account.css")
    ui.includeJavascript("emr", "account/account.js")

    def createAccount = (account.person.personId == null ? true : false);

    def genderOptions = [ [label: ui.message("emr.gender.M"), value: 'M'],
                          [label: ui.message("emr.gender.F"), value: 'F'] ]

    def privilegeLevelOptions = []
    privilegeLevels.each {
        privilegeLevelOptions.push([ label: ui.format(it), value: it.name ])
    }

    def allowedLocalesOptions = []
    allowedLocales.each {
        def displayLanguage = it.getDisplayLanguage(emrContext.userContext.locale);
        if (displayLanguage == "Haitian") { displayLanguage = "Haitian Creole" };  // Hack to fix the fact that ISO standard lists Creole as "Haitian"
        allowedLocalesOptions.push([ label: displayLanguage, value: it ]);
    }

    def providerRolesOptions = []
    providerRoles. each {
        providerRolesOptions.push([ label: ui.format(it), value: it.id ])
    }

%>

<script type="text/javascript">
    var breadcrumbs = [
        { icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/index.htm' },
        { label: "${ ui.message("emr.app.systemAdministration.label")}", link: '${ui.pageLink("coreapps", "systemadministration/systemAdministration")}' },
        { label: "${ ui.message("emr.task.accountManagement.label")}" , link: '${ui.pageLink("emr", "account/manageAccounts")}'},
        { label: "${ ui.message("emr.createAccount")}" }

    ];
</script>

<style type="text/css">
    #unlock-button {
        margin-top: 1em;
    }
</style>

<% if (account.locked) { %>
    <div id="locked-warning" class="note warning">
        <div class="icon"><i class="icon-warning-sign medium"></i></div>
        <div class="text">
            <p><strong>${ ui.message("emr.account.locked.title") }</strong></p>
            <p><em>${ ui.message("emr.account.locked.description") }</em></p>

            <button id="unlock-button" value="${ account.person.personId }">${ ui.message("emr.account.locked.button") }</button>

        </div>
    </div>
<% } %>

<h3>${ (createAccount) ? ui.message("emr.createAccount") : ui.message("emr.editAccount") }</h3>

<form method="post" id="accountForm">
	<fieldset>
		<legend>${ ui.message("emr.person.details") }</legend>

        ${ ui.includeFragment("uicommons", "field/text", [
            label: ui.message("emr.person.familyName"),
            formFieldName: "familyName", 
            initialValue: (account.familyName ?: '')
        ])}

        ${ ui.includeFragment("uicommons", "field/text", [
                label: ui.message("emr.person.givenName"),
                formFieldName: "givenName",
                initialValue: (account.givenName ?: '')
        ])}

        ${ ui.includeFragment("uicommons", "field/radioButtons", [
            label: ui.message("emr.gender"),
            formFieldName: "gender", 
            initialValue: (account.gender ?: 'M'), 
            options: genderOptions 
        ])}
	</fieldset>
	
	<fieldset>
		<legend>${ ui.message("emr.user.account.details") }</legend>
		<div class="emr_userDetails" <% if (!account.user) { %> style="display: none" <% } %>>

            ${ ui.includeFragment("emr", "field/checkbox", [ 
                label: ui.message("emr.user.enabled"), 
                id: "userEnabled", 
                formFieldName: "userEnabled", 
                value: "true", 
                checked: account.userEnabled 
            ])}

            ${ ui.includeFragment("uicommons", "field/text", [
                label: ui.message("emr.user.username"), 
                formFieldName: "username", 
                initialValue: (account.username ?: '') 
            ])}

            <% if (!account.password && !account.confirmPassword) { %>
                <button class="emr_passwordDetails emr_userDetails" type="button" onclick="javascript:jQuery('.emr_passwordDetails').toggle()">${ ui.message("emr.user.changeUserPassword") }</button>
                <p></p>
            <% } %>

            <p class="emr_passwordDetails" <% if(!account.password && !account.confirmPassword) { %>style="display: none"<% } %>>
                <label class="form-header" for="password">${ ui.message("emr.user.password") }</label>
                <input type="password" id="password" name="password" value="${ account.password ?: ''}" autocomplete="off"/>
                <label id="format-password">${ ui.message("emr.account.passwordFormat") }</label>
                ${ ui.includeFragment("uicommons", "fieldErrors", [ fieldName: "password" ])}
            </p>

            <p class="emr_passwordDetails" <% if(!account.password && !account.confirmPassword) { %>style="display: none"<% } %>>
                <label class="form-header" for="confirmPassword">${ ui.message("emr.user.confirmPassword") }</label>
                <input type="password" id="confirmPassword" name="confirmPassword" value="${ account.confirmPassword ?: '' }" autocomplete="off" />
                ${ ui.includeFragment("uicommons", "fieldErrors", [ fieldName: "confirmPassword" ])}
            </p>

            ${ ui.includeFragment("uicommons", "field/dropDown", [
                label: ui.message("emr.user.privilegeLevel"), 
                emptyOptionLabel: ui.message("emr.chooseOne"), 
                formFieldName: "privilegeLevel", 
                initialValue: (account.privilegeLevel ? account.privilegeLevel.getName() : ''), 
                options: privilegeLevelOptions
            ])}

            <p>
                ${ ui.includeFragment("uicommons", "field/dropDown", [
                    label: ui.message("emr.user.defaultLocale"), 
                    emptyOptionLabel: ui.message("emr.chooseOne"), 
                    formFieldName: "defaultLocale", 
                    initialValue: (account.defaultLocale ?: ''), 
                    options: allowedLocalesOptions 
                ])}
            </p>

            <p>
                <strong>${ ui.message("emr.user.Capabilities") }</strong>
            </p>

			<% capabilities.each{ %>
                ${ ui.includeFragment("emr", "field/checkbox", [ 
                    label: ui.format(it),
                    formFieldName: "capabilities", 
                    value: it.name, 
                    checked: account.capabilities?.contains(it) 
                ])}
            <% } %>
		</div>
		<div class="emr_userDetails">
			<% if(!account.user) { %>
				<button id="createUserAccountButton" type="button" onclick="javascript:emr_createUserAccount()"> ${ ui.message("emr.user.createUserAccount") }</button>
			<% } %>
		</div>
	</fieldset>
	
	<fieldset>
		<legend>${ ui.message("emr.provider.details") }</legend>
		<div class="emr_providerDetails">
            <p>
                ${ ui.includeFragment("uicommons", "field/dropDown", [
                        label: ui.message("emr.account.providerRole.label"),
                        emptyOptionLabel: ui.message("emr.chooseOne"),
                        formFieldName: "providerRole",
                        initialValue: (account.providerRole?.id ?: ''),
                        options: providerRolesOptions
                ])}
            </p>


        </div>
        <!-- TODO: put this back in (and hide the emr_providers div if !account.provider) once we make providers optional again -->
        <!--
		<div class="emr_providerDetails">
		<% if(!account.provider) { %>
			<button id="createProviderAccountButton" type="button" onclick="javascript:emr_createProviderAccount()">${ ui.message("emr.provider.createProviderAccount") }</button>
		<% } %>
		</div>
		-->

	</fieldset>

    <div>
        <input type="button" class="cancel" value="${ ui.message("emr.cancel") }" onclick="javascript:window.location='/${ contextPath }/emr/account/manageAccounts.page'" />
        <input type="submit" class="confirm" id="save-button" value="${ ui.message("emr.save") }"  />
    </div>

</form>

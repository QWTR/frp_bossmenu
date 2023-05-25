let ranks,GlobalSsn,GlobalJob

$('.userMenagment').fadeOut(0);
$('.Users').fadeIn(0);
$('.UsersAwansLab').fadeOut(0);
$('.container').fadeOut(0);

$('.CloseInput').click(()=>{
    $('.Users').css({'pointer-events':'all'})
    $('.inputVal').fadeOut(155);
});
$('.Cashin').click(function (e) { 
    $('.Users').css({'pointer-events':'none'})
    $('.inputVal').fadeOut(155);
    $('.inputValR').fadeIn(155);
});
$('.Cashout').click(function (e) { 
    $('.Users').css({'pointer-events':'none'})
    $('.inputVal').fadeOut(155);
    $('.inputValA').fadeIn(155);
});
$('.hire').click(function (e) { 
    $('.Users').css({'pointer-events':'none'})
    $('.inputVal').fadeOut(155);
    $('.inputValH').fadeIn(155);
});
$('.Dhire').click(function (e) { 
    $('.Users').css({'pointer-events':'none'})
    $('.inputVal').fadeOut(155);
    $('.inputValDH').fadeIn(155);
});

$('.closeRank').click(()=>{
    $('.UsersAwansLab').fadeOut(155);
    $('.userMenagment').css({'pointer-events':'all'})
});
$('.UserAwans').click(()=>{
    $('.UsersAwansLab').fadeIn(155);
    $('.userMenagment').css({'pointer-events':'none'})
});
$('.CloseMenagment').click(function (e) {
    $('.userMenagment').css({'pointer-events':'all'}) 
    $('.userMenagment').fadeOut(155);
    setTimeout(() => {
        $('.Users').fadeIn(155);
    }, 155);
    
});

$('.SubInVal').click(function (e) { 
    let value = $('.valToAdd').val()
    $.post('https://frp_bossmenu/wplac', JSON.stringify({value:value}));
});

$('.SubOutVal').click(function (e) { 
    let value = $('.valToRemove').val()
    $.post('https://frp_bossmenu/wyplac', JSON.stringify({value:value}));
});

$('.SubHireVal').click(function (e) { 
    let value = $('.valToHire').val()
    $.post('https://frp_bossmenu/zatrudnij', JSON.stringify({value:value}));
});

$('.SubDHireVal').click(function (e) { 
    let value = $('.valToDHire').val()
    $.post('https://frp_bossmenu/zwolnij', JSON.stringify({value:value}));
});


let CloseMenu = function () {
    $.post('https://frp_bossmenu/NUIFocusOff', JSON.stringify({}));
    $('.inputVal').fadeOut(0);
    $('.UsersAwansLab').fadeOut(0);
    $('.container').css({
        "transform":'translateY(0) scale(0.5)'
    });
    setTimeout(() => {
         $('.container').css({
            "transform":'translateY(120%) scale(0.5)'
        });
    }, 800);
    $('.fade').fadeIn(550);

    $("#TableUser").html("");
    $('.RankLab').html("");
}
$('.Close').click(function (e) { 
    CloseMenu();
});
document.onkeyup = function (data) {
    if (data.which == 27 ) {
        CloseMenu();
    }
};
function UserInfo(imie,nazwisko,ranga,odaznaka,czas,ssn,job) { 
    $('#NameToInsert').html(imie);
    $('#SnameToInsert').html(nazwisko);
    $('#RankToInsert').html(ranga);
    $('#BadageToInsert').html(odaznaka);
    // $('#TimeToInsert').html(czas);
    $('#SsnToInsert').html(ssn);

    $('.Users').fadeOut(155);
    setTimeout(() => {
        $('.userMenagment').fadeIn(155);
    }, 155);
    GlobalSsn = ssn;
    GlobalJob = job;
}

const UpdateRank = (grade,label) =>{
    $.post('https://frp_bossmenu/zmienstopien', JSON.stringify({grade:grade,ssn:GlobalSsn,job:GlobalJob}),(data)=> {
        if(data){
            $('.userMenagment').css({'pointer-events':'all'}) 
            $('.UsersAwansLab').fadeOut(50);
        }
    });
};

const UpdateAccountMoney = function(money){
    $(".accountBalance > p").html(`Stan Konta: $${money}`)
}

//fivem
window.addEventListener("message", function (event) {
    switch (event.data.action) {
        case"openMenu": 
            let ssn
            $('.container').fadeIn(155);
            $('.container').css({
                "transform":'translateY(0) scale(0.5)'
            });
            setTimeout(() => {
                 $('.container').css({
                    "transform":'translateY(0) scale(1)'
                });
            }, 800);
            setTimeout(() => {
                $('.fade').fadeOut(1050);
            }, 500);
            UpdateAccountMoney(event.data.money);
            
            event.data.employees.forEach(element => {
              
                $('#TableUser').append(`
                    <tr class=''>
                        <td>${element.firstname}</td>
                        <td>${element.lastname}</td>
                        <td id="${element.ssn}">${element.job.grade_label}</td>
                        <td>
                        <div class="UserMenu" onclick="UserInfo('${element.firstname}','${element.lastname}','${element.job.grade_label}','${element.job.badge}','11','${element.ssn}','${element.job.name}')">
                            <i class="fa-solid fa-arrow-right"></i>
                        </div>
                        </td>
                    </tr>
                `);
                if(element.job.name != 'police'){
                    $('.UserAbil').fadeOut(0);
                }else{
                    $('.UserAbil').fadeIn(0);
                }
            });
            for(let i in event.data.ranks){
                $('.RankLab').append(`<div class="RankN" onclick="UpdateRank('${event.data.ranks[i].grade}','${event.data.ranks[i].label}')">${event.data.ranks[i].label}</div>`);
            }
        break;
    }
});
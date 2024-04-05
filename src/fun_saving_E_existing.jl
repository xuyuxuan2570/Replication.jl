module fun_saving_E_exis

export fun_saving_E_existing

function fun_saving_E_existing(x)

    # Adjusting rate of return due to the endogenous borrowing constraint
    rho_t_ad = max.(rho_t, (rho_t.*(1+r./(1-ice_t)) .+ eta.*(rho_t - r./(1-ice_t))) ./ (1+r./(1-ice_t) - eta.*(rho_t - r./(1-ice_t))))

    # Other definitions
    age = x[1]  # age
    wealth = zeros(age_max)
    wealth[age] = x[2]  # wealth

    # Generating interest rate adjusted life-cycle earnings and others
    w = zeros(age_max)
    for i in age:age_max
        if i < age_T
            w[i] = m_t[i-age+1] * ((1+g_t) / (1+r))^(i-age)  # earnings
        else
            w[i] = 0
        end
    end

    # Computing life-time wealth
    if age < age_T
        A = sum(w) + (1+r) * wealth[age]
    else
        A = sum(w) + (1+rho_t_ad[1]) * wealth[age]
    end

    # Computing current optimal consumption and savings
    ratio = zeros(age_max)
    consumption = zeros(age_max)
    for i in age:age_max
        if i == age
            ratio[i] = 1
        elseif i < age_T
            ratio[i] = (bet_E * (1+r) / (1+g_t))^(1/sig) * (1+g_t) / (1+r) * ratio[i-1]
        else
            ratio[i] = (bet_E * (1+rho_t_ad[i-age+1]) / (1+g_t))^(1/sig) * (1+g_t) / (1+rho_t_ad[i-age+1]) * ratio[i-1]
        end

        if i == age
            consumption[i] = A / sum(ratio)
            if i < age_T
                wealth[i+1] = (wealth[i] * (1+r) + m_t[i-age+1] - consumption[i]) / (1+g_t)
            else
                wealth[i+1] = (wealth[i] * (1+rho_t_ad[i-age+1]) - consumption[i]) / (1+g_t)
            end
        elseif i < age_T
            consumption[i] = (bet_E * (1+r) / (1+g_t))^(1/sig) * consumption[i-1]
            wealth[i+1] = (wealth[i] * (1+r) + m_t[i-age+1] - consumption[i]) / (1+g_t)
        else
            consumption[i] = (bet_E * (1+rho_t_ad[i-age+1]) / (1+g_t))^(1/sig) * consumption[i-1]
            wealth[i+1] = (wealth[i] * (1+rho_t_ad[i-age+1]) - consumption[i]) / (1+g_t)
        end
    end

    # Definition of y
    y = [wealth'; consumption']
    return y
end

end #End of fun_saving_E_exis module
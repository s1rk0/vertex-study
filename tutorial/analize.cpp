#include "/pbs/home/i/iandriievsky/tutorial/MiModule/include/MiEvent.h"

R__LOAD_LIBRARY(/pbs/home/i/iandriievsky/tutorial/MiModule/lib/libMiModule.so);

void analyze_all()
{
    const char* labels[] = {"0nu", "2nu", "Bi214", "Tl208"};
    const char* files[] = {
        "/pbs/home/i/iandriievsky/iandriievsky/vertex-study/tutorial/0nu/Default.root",
        "/pbs/home/i/iandriievsky/iandriievsky/vertex-study/tutorial/2nu/Default.root",
        "/pbs/home/i/iandriievsky/iandriievsky/vertex-study/tutorial/Bi214/Default.root",
        "/pbs/home/i/iandriievsky/iandriievsky/vertex-study/tutorial/Tl208/Default.root"
    };

    for (int d = 0; d < 4; d++)
    {
        int pas_1 = 0, pas_2 = 0, pas_3 = 0;
        int pas_4 = 0, pas_5 = 0, pas_6 = 0;
        int full_N = 0;

        TFile* f = new TFile(files[d]);
        TTree* s = (TTree*) f->Get("Event");

        MiEvent* Eve = new MiEvent();
        s->SetBranchAddress("Eventdata", &Eve);

        int N = s->GetEntries();
        full_N = N;

        for (UInt_t i = 0; i < N; i++)
        {
            s->GetEntry(i);

            int n_calo = 0;
            int n_calov = 0;
            int n_neg = 0;
            double energy = 0.0;

            int n_rec = Eve->getPTD()->getpartv()->size();

            for (int j = 0; j < n_rec; j++)
            {
                n_calo = Eve->getPTD()->getpartv()->at(j).getcalohitv()->size();
                if (Eve->getPTD()->getpartv()->at(j).getcharge() == -1) n_neg++;
                for (int k = 0; k < n_calo; k++)
                {
                    energy += Eve->getPTD()->getpartv()->at(j).getcalohitv()->at(k).getE();
                }
                n_calov += n_calo;
            }

            if (n_calov == 2) pas_1++;
            if (n_calov == 2 && n_rec == 2) pas_2++;
            if (n_calov == 2 && n_rec == 2 && n_neg == 2) pas_3++;
            if (n_calov == 2 && n_rec == 2 && n_neg == 2 && energy > 2000.0) pas_4++;
            if (n_calov == 2 && n_rec == 2 && n_neg == 2 && energy > 2700.0) pas_5++;
            if (n_calov == 2 && n_rec == 2 && n_neg == 2 && energy > 2700.0 && energy < 3300.0) pas_6++;
        }

        std::cout << "\n===== " << labels[d] << " =====" << std::endl;
        std::cout << "Num events: " << full_N << std::endl;
        std::cout << "eps1 = " << (100.0 * pas_1) / full_N << "% +- " << (100.0 * sqrt(double(pas_1))) / full_N << "%" << std::endl;
        std::cout << "eps2 = " << (100.0 * pas_2) / full_N << "% +- " << (100.0 * sqrt(double(pas_2))) / full_N << "%" << std::endl;
        std::cout << "eps3 = " << (100.0 * pas_3) / full_N << "% +- " << (100.0 * sqrt(double(pas_3))) / full_N << "%" << std::endl;
        std::cout << "eps4 = " << (100.0 * pas_4) / full_N << "% +- " << (100.0 * sqrt(double(pas_4))) / full_N << "%" << std::endl;
        std::cout << "eps5 = " << (100.0 * pas_5) / full_N << "% +- " << (100.0 * sqrt(double(pas_5))) / full_N << "%" << std::endl;
        std::cout << "eps6 = " << (100.0 * pas_6) / full_N << "% +- " << (100.0 * sqrt(double(pas_6))) / full_N << "%" << std::endl;

        f->Close();
    }
}

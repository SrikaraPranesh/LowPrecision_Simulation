%TEST Generates the tables and plots used in the 
% manuscript 'Simulating Low Precision Floating-Point
% Arithmetic -- N.J.Higham and S.Pranesh'

clear all; close all;

addpath('MainFunctions/')
addpath('MainScripts/')

euler_exp_round_modes
LUTime;
euler_exp;
sum_series;
solve_test;
matmult;

movefile('*.txt','results')
movefile('*.mat','results')